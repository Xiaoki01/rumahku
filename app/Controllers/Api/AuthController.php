<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\UserModel;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthController extends BaseController
{
    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
    }

    //reg
    public function register()
    {
        $isAuthenticated = isset($this->request->userData);
        $json = $this->request->getJSON(true);

        $allowedRoles = $isAuthenticated
            ? ['admin', 'pengguna', 'kepala_proyek', 'mandor']
            : ['pengguna'];

        $rules = [
            'name'     => 'required|min_length[3]',
            'email'    => 'required|valid_email|is_unique[users.email]',
            'password' => 'required|min_length[6]',
            'role'     => 'required|in_list[' . implode(',', $allowedRoles) . ']',
            'phone'    => 'permit_empty|numeric'
        ];

        $validation = \Config\Services::validation();
        if (!$validation->setRules($rules)->run($json ?: [])) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $validation->getErrors()
            ])->setStatusCode(400);
        }

        $role = $isAuthenticated ? ($json['role'] ?? 'pengguna') : 'pengguna';

        $data = [
            'name'     => $json['name'],
            'email'    => $json['email'],
            'password' => password_hash($json['password'], PASSWORD_DEFAULT),
            'role'     => $role,
            'phone'    => $json['phone'] ?? null
        ];

        if ($this->userModel->insert($data)) {
            $userId = $this->userModel->getInsertID();
            $message = $isAuthenticated ? 'Akun berhasil ditambahkan' : 'Registrasi berhasil! Silakan login';

            return $this->response->setJSON([
                'status' => 'success',
                'message' => $message,
                'data' => [
                    'user' => [
                        'id' => $userId,
                        'name' => $data['name'],
                        'email' => $data['email'],
                        'role' => $data['role']
                    ]
                ]
            ])->setStatusCode(201);
        }

        return $this->response->setJSON([
            'status' => 'error',
            'message' => 'Registrasi gagal'
        ])->setStatusCode(500);
    }

    //login
    public function login()
    {
        $json = $this->request->getJSON(true);
        $rules = [
            'email'    => 'required|valid_email',
            'password' => 'required'
        ];

        $validation = \Config\Services::validation();
        if (!$validation->setRules($rules)->run($json ?: [])) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $validation->getErrors()
            ])->setStatusCode(400);
        }

        $user = $this->userModel
            ->select('id, name, email, password, role, phone')
            ->where('email', $json['email'])
            ->first();

        if (!$user || !password_verify($json['password'], $user['password'])) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Email atau password salah'
            ])->setStatusCode(401);
        }

        $key = getenv('jwt.secret') ?: 'rahasia-jwt-rumahku-2025-change-in-production';
        $expire = getenv('jwt.expire') ?: 86400;

        $payload = [
            'iat' => time(),
            'exp' => time() + $expire,
            'data' => [
                'id'    => $user['id'],
                'name'  => $user['name'],
                'email' => $user['email'],
                'role'  => $user['role']
            ]
        ];

        $token = JWT::encode($payload, $key, 'HS256');

        unset($user['password']);

        return $this->response->setJSON([
            'status' => 'success',
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $token
            ]
        ]);
    }


    public function profile()
    {
        $userData = $this->request->userData ?? null;

        if (!$userData) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Token invalid atau tidak terbaca'
            ])->setStatusCode(401);
        }

        $user = $this->userModel->find($userData->id);

        if (!$user) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'User tidak ditemukan'
            ])->setStatusCode(404);
        }

        return $this->response->setJSON([
            'status' => 'success',
            'data' => $user
        ]);
    }

public function updateProfile()
{
    $request = $this->request;
    $userData = $request->userData ?? null;

    if (!$userData) {
        return $this->response->setStatusCode(401)->setJSON(['status' => 'error', 'message' => 'Sesi berakhir']);
    }

    $json = $request->getJSON(true);
    $userId = $userData->id;

    $rules = [
        'name'  => 'required|min_length[3]',
        'email' => "required|valid_email|is_unique[users.email,id,{$userId}]",
        'phone' => 'permit_empty|numeric|min_length[10]'
    ];

    if (!$this->validate($rules)) {
        return $this->response->setStatusCode(400)->setJSON([
            'status'  => 'error',
            'message' => 'Validasi gagal',
            'errors'  => $this->validator->getErrors()
        ]);
    }

    $data = [
        'name'  => trim($json['name']),
        'email' => trim($json['email']),
        'phone' => $json['phone'] ?? null
    ];

    //update
    if ($this->userModel->update($userId, $data)) {
        $updatedUser = $this->userModel->find($userId);
        
        return $this->response->setJSON([
            'status'  => 'success',
            'message' => 'Profile berhasil diperbarui',
            'data'    => $updatedUser
        ]);
    }

    return $this->response->setStatusCode(500)->setJSON(['status' => 'error', 'message' => 'Gagal update database']);
}
    //change
    public function changePassword()
{
    $userData = $this->request->userData ?? null;
    $json = $this->request->getJSON(true);

    $rules = [
        'old_password'     => 'required',
        'new_password'     => 'required|min_length[6]',
        'confirm_password' => 'required|matches[new_password]'
    ];

    if (!$this->validate($rules)) {
        return $this->response->setStatusCode(400)->setJSON([
            'status' => 'error', 
            'message' => 'Validasi gagal', 
            'errors' => $this->validator->getErrors()
        ]);
    }

    $user = $this->userModel->select('id, password')->find($userData->id);

    if (!password_verify($json['old_password'], $user['password'])) {
        return $this->response->setStatusCode(400)->setJSON([
            'status'  => 'error',
            'message' => 'Password lama tidak sesuai'
        ]);
    }

    //Update password
    $this->userModel->update($userData->id, [
        'password' => password_hash($json['new_password'], PASSWORD_DEFAULT)
    ]);

    return $this->response->setJSON([
        'status'  => 'success',
        'message' => 'Password berhasil diubah'
    ]);
}
}
