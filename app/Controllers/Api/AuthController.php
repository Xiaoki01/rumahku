<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\UserModel;

class AuthController extends BaseController
{
    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
    }

    private function base64UrlEncode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    public function register()
    {
        $isAuthenticated = isset($this->request->userData);

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

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $this->validator->getErrors()
            ])->setStatusCode(400);
        }

        $role = $isAuthenticated
            ? $this->request->getVar('role')
            : 'pengguna';

        $data = [
            'name'     => $this->request->getVar('name'),
            'email'    => $this->request->getVar('email'),
            'password' => password_hash($this->request->getVar('password'), PASSWORD_DEFAULT),
            'role'     => $role,
            'phone'    => $this->request->getVar('phone')
        ];

        if ($this->userModel->insert($data)) {
            $userId = $this->userModel->getInsertID();
            $message = $isAuthenticated
                ? 'Akun berhasil ditambahkan'
                : 'Registrasi berhasil! Silakan login';

            return $this->response->setJSON([
                'status' => 'success',
                'message' => $message,
                'data' => [
                    'id' => $userId,
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'role' => $data['role']
                ]
            ])->setStatusCode(201);
        }

        return $this->response->setJSON([
            'status' => 'error',
            'message' => 'Registrasi gagal'
        ])->setStatusCode(500);
    }

    public function login()
    {
        $rules = [
            'email'    => 'required|valid_email',
            'password' => 'required'
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $this->validator->getErrors()
            ])->setStatusCode(400);
        }

        $email = $this->request->getVar('email');
        $password = $this->request->getVar('password');

        $user = $this->userModel
            ->select('id, name, email, password, role, phone')
            ->where('email', $email)
            ->first();

        if (!$user || !password_verify($password, $user['password'])) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Email atau password salah'
            ])->setStatusCode(401);
        }

        $key = getenv('jwt.secret');
        $expire = getenv('jwt.expire') ?: 86400;

        $header = ['typ' => 'JWT', 'alg' => 'HS256'];

        $payload = [
            'iat' => time(),
            'exp' => time() + $expire,
            'data' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'role' => $user['role']
            ]
        ];

        $headerEncoded  = $this->base64UrlEncode(json_encode($header));
        $payloadEncoded = $this->base64UrlEncode(json_encode($payload));
        $signature      = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", $key, true);
        $signatureEncoded = $this->base64UrlEncode($signature);

        $token = "$headerEncoded.$payloadEncoded.$signatureEncoded";

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
                'message' => 'Token invalid'
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
        $userData = $this->request->userData ?? null;

        if (!$userData) {
            return $this->response->setStatusCode(401)->setJSON([
                'status'  => 'error',
                'message' => 'Token invalid'
            ]);
        }

        $userId = $userData->id;
        $json   = $this->request->getJSON(true);

        if (!is_array($json)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status'  => 'error',
                'message' => 'Invalid JSON payload'
            ]);
        }

        // Validasi email unik kecuali milik sendiri
        $rules = [
            'name'  => 'required|min_length[3]',
            'email' => "required|valid_email|is_unique[users.email,id,{$userId}]",
            'phone' => 'permit_empty|numeric|min_length[10]|max_length[15]'
        ];

        $validation = \Config\Services::validation();
        if (!$validation->setRules($rules)->run($json)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status'  => 'error',
                'message' => 'Validasi gagal',
                'errors'  => $validation->getErrors()
            ]);
        }

        $data = [
            'name'  => trim($json['name']),
            'email' => trim($json['email']),
            'phone' => $json['phone'] ?? null
        ];

        // PERBAIKAN: Gunakan method skipValidation() dan langsung update
        try {
            $db = \Config\Database::connect();
            $builder = $db->table('users');
            
            $result = $builder->where('id', $userId)->update($data);
            
            if (!$result) {
                return $this->response->setStatusCode(500)->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal memperbarui profile',
                    'errors'  => ['database' => 'Update query failed']
                ]);
            }

            // Ambil data fresh dari database
            $user = $this->userModel->find($userId);

            if (!$user) {
                return $this->response->setStatusCode(404)->setJSON([
                    'status'  => 'error',
                    'message' => 'User tidak ditemukan setelah update'
                ]);
            }

            return $this->response->setJSON([
                'status'  => 'success',
                'message' => 'Profile berhasil diperbarui',
                'data'    => $user
            ]);

        } catch (\Exception $e) {
            log_message('error', 'Update profile error: ' . $e->getMessage());
            
            return $this->response->setStatusCode(500)->setJSON([
                'status'  => 'error',
                'message' => 'Terjadi kesalahan server',
                'debug'   => ENVIRONMENT === 'development' ? $e->getMessage() : null
            ]);
        }
    }

    public function changePassword()
    {
        $userData = $this->request->userData ?? null;

        if (!$userData) {
            return $this->response->setStatusCode(401)->setJSON([
                'status'  => 'error',
                'message' => 'Token invalid'
            ]);
        }

        $json = $this->request->getJSON(true);

        if (!is_array($json)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status'  => 'error',
                'message' => 'Invalid JSON payload'
            ]);
        }

        $rules = [
            'old_password'     => 'required',
            'new_password'     => 'required|min_length[6]',
            'confirm_password' => 'required|matches[new_password]'
        ];

        $validation = \Config\Services::validation();
        if (!$validation->setRules($rules)->run($json)) {
            return $this->response->setStatusCode(400)->setJSON([
                'status'  => 'error',
                'message' => 'Validasi gagal',
                'errors'  => $validation->getErrors()
            ]);
        }

        // Ambil user dengan password (select explicit untuk bypass afterFind)
        $user = $this->userModel
            ->select('id, password')
            ->where('id', $userData->id)
            ->first();

        if (!$user) {
            return $this->response->setStatusCode(404)->setJSON([
                'status'  => 'error',
                'message' => 'User tidak ditemukan'
            ]);
        }

        if (!password_verify($json['old_password'], $user['password'])) {
            return $this->response->setStatusCode(400)->setJSON([
                'status'  => 'error',
                'message' => 'Password lama tidak sesuai'
            ]);
        }

        if (password_verify($json['new_password'], $user['password'])) {
            return $this->response->setStatusCode(400)->setJSON([
                'status'  => 'error',
                'message' => 'Password baru harus berbeda dari password lama'
            ]);
        }

        $updateData = [
            'password' => password_hash($json['new_password'], PASSWORD_DEFAULT)
        ];

        // PERBAIKAN: Langsung update ke database tanpa validation model
        try {
            $db = \Config\Database::connect();
            $builder = $db->table('users');
            
            $result = $builder->where('id', $userData->id)->update($updateData);
            
            if (!$result) {
                return $this->response->setStatusCode(500)->setJSON([
                    'status'  => 'error',
                    'message' => 'Gagal mengubah password',
                    'errors'  => ['database' => 'Update query failed']
                ]);
            }

            return $this->response->setJSON([
                'status'  => 'success',
                'message' => 'Password berhasil diubah'
            ]);

        } catch (\Exception $e) {
            log_message('error', 'Change password error: ' . $e->getMessage());
            
            return $this->response->setStatusCode(500)->setJSON([
                'status'  => 'error',
                'message' => 'Terjadi kesalahan server',
                'debug'   => ENVIRONMENT === 'development' ? $e->getMessage() : null
            ]);
        }
    }
}