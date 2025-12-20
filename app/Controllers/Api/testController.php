<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class TestController extends ResourceController
{
    public function testJwt()
    {
        $userData = session()->get('jwt_user');
        
        return $this->respond([
            'status' => 'success',
            'message' => 'JWT Test',
            'data' => [
                'session_exists' => session()->has('jwt_user'),
                'userData' => $userData,
                'userData_type' => gettype($userData),
                'has_role' => isset($userData['role']) ? 'yes' : 'no',
                'role_value' => $userData['role'] ?? 'not set',
                'user_id' => $userData['id'] ?? 'not set',
                'user_name' => $userData['name'] ?? 'not set',
            ]
        ]);
    }
}