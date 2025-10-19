<?php

namespace App\Helpers;

class Hmac
{
  /**
   * Sign a payload with a secret key.
   *
   * @param array $payload
   * @param string $secret
   * @return string
   */
  public static function sign(array $payload, string $secret): string
  {
    $data = self::preparePayload($payload);
    $hash = hash_hmac('sha256', $data, $secret, true);
    return self::base64UrlEncode($hash);
  }

  /**
   * Verify a signature against a payload and secret key.
   *
   * @param string $signature
   * @param array $payload
   * @param string $secret
   * @return bool
   */
  public static function verify(string $signature, array $payload, string $secret): bool
  {
    $expectedSignature = self::sign($payload, $secret);
    return hash_equals($expectedSignature, $signature);
  }

  /**
   * Prepare the payload for signing by sorting keys and encoding as a query string.
   *
   * @param array $payload
   * @return string
   */
  private static function preparePayload(array $payload): string
  {
    ksort($payload);
    return http_build_query($payload);
  }

  /**
   * Encode data in Base64URL format.
   *
   * @param string $data
   * @return string
   */
  public static function base64UrlEncode(string $data): string
  {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
  }

  /**
   * Decode data from Base64URL format.
   *
   * @param string $data
   * @return string|false
   */
  public static function base64UrlDecode(string $data): string|false
  {
    $normalized = strtr($data, '-_', '+/');
    $padding = (4 - strlen($normalized) % 4) % 4;
    return base64_decode($normalized . str_repeat('=', $padding));
  }
}
