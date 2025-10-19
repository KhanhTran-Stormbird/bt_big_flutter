<?php

namespace App\Services;

use App\Models\FaceSample;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Throwable;

class FaceService
{
  /**
   * "Enroll" a face by saving the sample image.
   *
   * @param User $user
   * @param UploadedFile $image
   * @return FaceSample
   */
  public function enroll(User $user, UploadedFile $image): FaceSample
  {
    $directory = sprintf('users/%d', $user->id);
    $disk = Storage::disk('faces');
    $rootPath = $disk->path('');
    if (!is_dir($rootPath)) {
      if (!mkdir($rootPath, 0755, true) && !is_dir($rootPath)) {
        throw new RuntimeException(sprintf('Unable to initialise faces storage at %s', $rootPath));
      }
    }

    $absoluteDirectory = $disk->path($directory);
    if (!is_dir($absoluteDirectory)) {
      if (!mkdir($absoluteDirectory, 0755, true) && !is_dir($absoluteDirectory)) {
        throw new RuntimeException(sprintf('Unable to create directory %s', $absoluteDirectory));
      }
    }

    $fileName = $image->hashName();
    $path = $image->storeAs($directory, $fileName, 'faces');

    $absolutePath = $disk->path($path);
    $hash = $this->hashFile($absolutePath);

    try {
      return DB::transaction(static function () use ($user, $path, $hash) {
        return FaceSample::create([
          'user_id' => $user->id,
          'path' => $path,
          'embedding' => ['hash' => $hash],
          'quality_score' => null,
        ]);
      });
    } catch (Throwable $throwable) {
      Storage::disk('faces')->delete($path);
      throw $throwable;
    }
  }

  /**
   * Compare the uploaded image with samples stored for a user.
   *
   * @param User $user
   * @param UploadedFile $image
   * @return array{matched: bool, sample_id: int|null}
   */
  public function match(User $user, UploadedFile $image): array
  {
    $providedHash = $this->hashFile($image->getRealPath());
    $disk = Storage::disk('faces');

    foreach ($user->faceSamples as $sample) {
      $storedHash = $sample->embedding['hash'] ?? null;

      if (!$storedHash) {
        $storedHash = $this->hashFile($disk->path($sample->path));
        $sample->update(['embedding' => ['hash' => $storedHash]]);
      }

      if (hash_equals($storedHash, $providedHash)) {
        return [
          'matched' => true,
          'sample_id' => $sample->id,
        ];
      }
    }

    return [
      'matched' => false,
      'sample_id' => null,
    ];
  }

  /**
   * "Recognize" a face from an image.
   *
   * @param UploadedFile $image
   * @return array A stubbed recognition result.
   */
  public function recognize(UploadedFile $image): array
  {
    // This is a stub. A real implementation would compare the image
    // against enrolled face embeddings.
    return [
      'user_id' => null, // or a mocked user ID
      'distance' => 1.0, // higher means less similar
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
}
