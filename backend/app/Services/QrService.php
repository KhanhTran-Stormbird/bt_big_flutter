<?php

namespace App\Services;

use App\Helpers\Hmac;
use App\Models\Session;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class QrService
{
  protected string $secret;

  public function __construct()
  {
    $this->secret = config('app.key');
  }

  /**
   * Generate a QR code for a session.
   *
   * @param Session $session
   * @return array
   */
  public function generateQrCode(Session $session): array
  {
    $ttl = config('face.qr_ttl', 60);
    $payload = [
      'sid' => $session->id,
      'exp' => time() + $ttl,
    ];

    $payload['sig'] = Hmac::sign($payload, $this->secret);

    $jsonPayload = json_encode($payload);

    $svg = QrCode::size(256)->generate($jsonPayload);

    return [
      'svg' => 'data:image/svg+xml;base64,' . base64_encode($svg),
      'ttl' => $ttl,
    ];
  }

  /**
   * Verify the QR code payload and return the session ID.
   *
   * @param string $qrJson
   * @return int|null
   */
  public function verifyQrCode(string $qrJson): ?int
  {
    $payload = json_decode($qrJson, true);

    if (!isset($payload['sid'], $payload['exp'], $payload['sig'])) {
      return null;
    }

    if ($payload['exp'] < time()) {
      return null; // Expired
    }

    $signature = $payload['sig'];
    unset($payload['sig']);

    if (!Hmac::verify($signature, $payload, $this->secret)) {
      return null; // Invalid signature
    }

    return $payload['sid'];
  }
}