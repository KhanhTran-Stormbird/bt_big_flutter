<?php

namespace App\Services;

use App\Models\FaceSample;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Throwable;

class FaceService
{
  protected string $provider;
  protected string $baseUrl;
  /** @var array{extract:string,match:string} */
  protected array $paths;
  protected float $threshold;
  protected int $timeout;

  public function __construct()
  {
    $this->provider = (string) config('face.provider', 'stub');
    $this->baseUrl = (string) config('face.base_url', '');
    $this->paths = config('face.paths', ['extract' => '/extract', 'match' => '/match']);
    $this->threshold = (float) config('face.threshold', 0.6);
    $this->timeout = (int) config('face.timeout', 10);
  }

  /**
   * Enrol a new face sample for a user.
   */
  public function enroll(User $user, UploadedFile $image): FaceSample
  {
    $disk = Storage::disk('faces');
    $rootPath = $disk->path('');
    if (!is_dir($rootPath)) {
      if (!mkdir($rootPath, 0755, true) && !is_dir($rootPath)) {
        throw new RuntimeException(sprintf('Unable to initialise faces storage at %s', $rootPath));
      }
    }

    $directory = sprintf('users/%d', $user->id);
    $absoluteDirectory = $disk->path($directory);
    if (!is_dir($absoluteDirectory)) {
      if (!mkdir($absoluteDirectory, 0755, true) && !is_dir($absoluteDirectory)) {
        throw new RuntimeException(sprintf('Unable to create directory %s', $absoluteDirectory));
      }
    }

    $fileName = $image->hashName();
    $relativePath = $image->storeAs($directory, $fileName, 'faces');
    $absolutePath = $disk->path($relativePath);

    $embedding = $this->buildEmbedding($absolutePath);

    try {
      return DB::transaction(function () use ($user, $relativePath, $embedding) {
        return FaceSample::create([
          'user_id' => $user->id,
          'path' => $relativePath,
          'embedding' => $embedding,
          'quality_score' => null,
        ]);
      });
    } catch (Throwable $throwable) {
      Storage::disk('faces')->delete($relativePath);
      throw $throwable;
    }
  }

  /**
   * Compare an uploaded image against the user's enrolled samples.
   *
   * @return array{matched: bool, sample_id: int|null, distance: float|null}
   */
  public function match(User $user, UploadedFile $image): array
  {
    $targetEmbedding = $this->buildEmbedding($this->resolveAbsolutePath($image));
    $targetVector = $this->embeddingVector($targetEmbedding);

    foreach ($user->faceSamples as $sample) {
      $embedding = $sample->embedding ?? [];

      if ($this->provider === 'stub') {
        $storedHash = $embedding['hash'] ?? null;
        $targetHash = $targetEmbedding['hash'] ?? null;
        if ($storedHash && $targetHash && hash_equals($storedHash, $targetHash)) {
          return [
            'matched' => true,
            'sample_id' => $sample->id,
            'distance' => 0.0,
          ];
        }
        continue;
      }

      $storedVector = $this->ensureSampleVector($sample, $embedding);
      if ($storedVector && $targetVector) {
        $distance = $this->compareVectors($storedVector, $targetVector);
        if ($distance <= $this->threshold) {
          return [
            'matched' => true,
            'sample_id' => $sample->id,
            'distance' => $distance,
          ];
        }
      }
    }

    return [
      'matched' => false,
      'sample_id' => null,
      'distance' => null,
    ];
  }

  /**
   * Generate an embedding payload for a file path.
   *
   * @return array<string,mixed>
   */
  protected function buildEmbedding(string $absolutePath): array
  {
    if ($this->provider === 'http') {
      $vector = $this->requestEmbedding($absolutePath);
      return ['vector' => $vector];
    }

    return ['hash' => $this->hashFile($absolutePath)];
  }

  /**
   * Ensure a face sample has a numeric embedding vector available.
   *
   * @param array<string,mixed> $embedding
   * @return array<int,float>|null
   */
  protected function ensureSampleVector(FaceSample $sample, array &$embedding): ?array
  {
    if ($this->provider !== 'http') {
      return null;
    }

    $vector = $this->embeddingVector($embedding);
    if ($vector) {
      return $vector;
    }

    $disk = Storage::disk('faces');
    $absolutePath = $disk->path($sample->path);
    $vector = $this->requestEmbedding($absolutePath);
    $embedding = ['vector' => $vector];
    $sample->update(['embedding' => $embedding]);

    return $vector;
  }

  /**
   * @param array<string,mixed> $embedding
   * @return array<int,float>|null
   */
  protected function embeddingVector(array $embedding): ?array
  {
    $vector = $embedding['vector'] ?? null;
    if (!is_array($vector) || empty($vector)) {
      return null;
    }

    return array_map(static fn($v) => (float) $v, $vector);
  }

  /**
   * Request an embedding vector from the external AI service.
   *
   * @return array<int,float>
   */
  protected function requestEmbedding(string $absolutePath): array
  {
    if (empty($this->baseUrl)) {
      throw new RuntimeException('Face API base URL is not configured.');
    }

    $contents = @file_get_contents($absolutePath);
    if ($contents === false) {
      throw new RuntimeException("Unable to read image at {$absolutePath}");
    }

    $response = Http::timeout($this->timeout)
      ->acceptJson()
      ->attach('image', $contents, basename($absolutePath))
      ->post($this->baseUrl . $this->paths['extract']);

    if (!$response->ok()) {
      throw new RuntimeException('Face API extract failed: ' . $response->body());
    }

    $payload = $response->json('embedding');
    if (!is_array($payload) || empty($payload)) {
      throw new RuntimeException('Face API extract returned invalid embedding.');
    }

    return array_map(static fn($v) => (float) $v, $payload);
  }

  /**
   * Compare two embedding vectors and return the distance.
   *
   * @param array<int,float> $source
   * @param array<int,float> $target
   */
  protected function compareVectors(array $source, array $target): float
  {
    if (count($source) !== count($target)) {
      throw new RuntimeException('Embedding length mismatch.');
    }

    $response = Http::timeout($this->timeout)
      ->acceptJson()
      ->post($this->baseUrl . $this->paths['match'], [
        'source' => array_values($source),
        'target' => array_values($target),
      ]);

    if (!$response->ok()) {
      throw new RuntimeException('Face API match failed: ' . $response->body());
    }

    $distance = $response->json('distance');
    if (!is_numeric($distance)) {
      throw new RuntimeException('Face API match returned invalid distance.');
    }

    return (float) $distance;
  }

  /**
   * Stub recognition endpoint placeholder.
   */
  public function recognize(UploadedFile $image): array
  {
    if ($this->provider === 'http') {
      $vector = $this->requestEmbedding($this->resolveAbsolutePath($image));
      return [
        'user_id' => null,
        'distance' => null,
        'embedding' => $vector,
      ];
    }

    return [
      'user_id' => null,
      'distance' => 1.0,
    ];
  }

  protected function hashFile(string $path): string
  {
    $hash = @hash_file('sha1', $path);
    if ($hash === false) {
      throw new RuntimeException("Unable to hash file at {$path}");
    }

    return $hash;
  }

  protected function resolveAbsolutePath(UploadedFile $file): string
  {
    $path = $file->getRealPath();
    if ($path === false || $path === null) {
      $path = $file->getPathname();
    }

    if (!is_string($path) || !file_exists($path)) {
      throw new RuntimeException('Unable to access uploaded image file.');
    }

    return $path;
  }
}
