<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class JwtAuth implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $key = getenv('jwt.secret');
        $header = $request->getHeaderLine('Authorization');
        
        if (!$header) {
            return service('response')->setJSON([
                'status' => 'error',
                'message' => 'Token tidak ditemukan'
            ])->setStatusCode(401);
        }
        
        try {
            // 1. Extract token from "Bearer <token>"
            if (strpos($header, 'Bearer ') !== 0) {
                throw new \Exception('Format token harus Bearer');
            }
            $token = str_replace('Bearer ', '', $header);
            
            // 2. Decode JWT manually
            $tokenParts = explode('.', $token);
            if (count($tokenParts) !== 3) {
                throw new \Exception('Format token tidak valid (harus 3 bagian)');
            }
            
            list($header64, $payload64, $signature64) = $tokenParts;
            
            // 3. Verify signature
            $signature = base64_decode(strtr($signature64, '-_', '+/'));
            $expectedSignature = hash_hmac('sha256', "$header64.$payload64", $key, true);
            
            if (!hash_equals($signature, $expectedSignature)) {
                throw new \Exception('Signature/Tanda tangan token tidak valid');
            }
            
            // 4. Decode payload
            $payload = json_decode(base64_decode(strtr($payload64, '-_', '+/')));
            
            if (!$payload) {
                throw new \Exception('Payload tidak terbaca');
            }
            
            // 5. Check expiration
            if (isset($payload->exp) && $payload->exp < time()) {
                throw new \Exception('Token sudah kadaluwarsa (Expired)');
            }
            
            // 6. PENTING: Simpan ke userData (sesuai controller kita)
            // Pastikan struktur payload token login Anda menyimpan data user di dalam properti "data"
            $request->userData = $payload->data;
            
        } catch (\Exception $e) {
            return service('response')->setJSON([
                'status' => 'error',
                'message' => 'Akses ditolak: ' . $e->getMessage()
            ])->setStatusCode(401);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // Do nothing
    }
}