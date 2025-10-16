<?php

namespace App\Services;

use App\Models\FaceSample;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class FaceService
{
    public function extractEmbedding(string $absoluteImagePath): ?array
    {
        $provider = config('face.provider');
        if ($provider === 'http') {
            $base = (string) config('face.base_url');
            $path = (string) config('face.paths.extract');
            $timeout = (int) config('face.timeout');

            if (empty($base)) {
                return null;
            }

            $res = Http::timeout($timeout)
                ->attach('image', file_get_contents($absoluteImagePath), basename($absoluteImagePath))
                ->post($base.$path);

            if (!$res->successful()) {
                return null;
            }

            $data = $res->json();
            // Accept either {embedding: [...]} or raw [...]
            $embedding = $data['embedding'] ?? $data;
            return is_array($embedding) ? $embedding : null;
        }

        // stub provider: return a dummy embedding
        return array_fill(0, 128, 0.1);
    }

    public function distance(array $a, array $b): ?float
    {
        $provider = config('face.provider');
        if ($provider === 'http') {
            $base = (string) config('face.base_url');
            $path = (string) config('face.paths.match');
            $timeout = (int) config('face.timeout');

            if (empty($base)) {
                return null;
            }

            $res = Http::timeout($timeout)
                ->post($base.$path, [
                    'source' => $a,
                    'target' => $b,
                ]);
            if (!$res->successful()) {
                return null;
            }
            $data = $res->json();
            // Accept {distance: 0.3} or raw float
            return (float) ($data['distance'] ?? $data);
        }

        // stub provider: simple L1 distance as placeholder
        $n = min(count($a), count($b));
        if ($n === 0) return null;
        $sum = 0.0;
        for ($i = 0; $i < $n; $i++) {
            $sum += abs(((float) $a[$i]) - ((float) $b[$i]));
        }
        return $sum / $n;
    }

    public function bestMatchForUser(User $user, array $candidateEmbedding): array
    {
        $samples = $user->faceSamples()->get();
        $best = null;
        $bestDist = null;
        foreach ($samples as $s) {
            $embed = $s->embedding ?? [];
            if (!is_array($embed) || empty($embed)) continue;
            $dist = $this->distance($embed, $candidateEmbedding);
            if ($dist === null) continue;
            if ($bestDist === null || $dist < $bestDist) {
                $bestDist = $dist;
                $best = $s;
            }
        }
        return ['sample' => $best, 'distance' => $bestDist];
    }

    public function enroll(User $user, string $disk, string $storedPath): ?FaceSample
    {
        $absolute = Storage::disk($disk)->path($storedPath);
        $embedding = $this->extractEmbedding($absolute);
        if (!$embedding) return null;

        return FaceSample::create([
            'user_id' => $user->id,
            'path' => $storedPath,
            'embedding' => $embedding,
            'quality_score' => null,
        ]);
    }

    public function verify(User $user, string $absoluteImagePath): array
    {
        $embedding = $this->extractEmbedding($absoluteImagePath);
        if (!$embedding) {
            return ['is_match' => false, 'distance' => null, 'sample_id' => null];
        }
        $best = $this->bestMatchForUser($user, $embedding);
        $dist = $best['distance'];
        $threshold = (float) config('face.threshold', 0.6);
        $isMatch = $dist !== null && $dist <= $threshold;
        return [
            'is_match' => $isMatch,
            'distance' => $dist,
            'sample_id' => $best['sample']?->id,
        ];
    }
}

