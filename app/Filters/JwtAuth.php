<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtAuth implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $key = getenv('jwt.secret') ?: 'rahasia-jwt-rumahku-2025-change-in-production';
        $header = $request->getHeaderLine('Authorization');

        if (!$header) {
            return $this->errorResponse('Token tidak ditemukan di header');
        }

        try {
            if (!preg_match('/Bearer\s(\S+)/', $header, $matches)) {
                throw new \Exception('Format header Authorization salah');
            }
            
            $token = $matches[1];
            $decoded = JWT::decode($token, new Key($key, 'HS256'));
            
            $request->userData = $decoded->data;

        } catch (\Firebase\JWT\ExpiredException $e) {
            return $this->errorResponse('Sesi Anda telah berakhir, silakan login kembali');
        } catch (\Exception $e) {
            return $this->errorResponse('Token invalid atau tidak sah');
        }

        return null;
    }

    private function errorResponse($message)
    {
        return service('response')->setJSON([
            'status' => 'error',
            'message' => $message
        ])->setStatusCode(401);
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null) {}
}