<?php

namespace App\Services;

use App\Models\FaceSample;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
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
      mkdir($rootPath, 0755, true);
    }

    $disk->makeDirectory($directory, 0755, true);

    $path = $image->store(
      $directory,
      'faces'
    );

    try {
      return DB::transaction(static function () use ($user, $path) {
        return FaceSample::create([
          'user_id' => $user->id,
          'path' => $path,
          'embedding' => null,
          'quality_score' => null,
        ]);
      });
    } catch (Throwable $throwable) {
      Storage::disk('faces')->delete($path);
      throw $throwable;
    }
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
}
