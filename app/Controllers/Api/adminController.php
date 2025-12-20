<?php

namespace App\Controllers\Api;

use App\Models\UserModel;
use CodeIgniter\API\ResponseTrait;
use CodeIgniter\RESTful\ResourceController;

class AdminController extends ResourceController
{
    use ResponseTrait;

    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
    }


    private function getCurrentUser()
    {
        /** @var \CodeIgniter\HTTP\IncomingRequest $request */
        $request = $this->request;

        return $request->userData ?? null;
    }


    private function isAdmin()
    {
        $user = $this->getCurrentUser();
        return $user && isset($user->role) && $user->role === 'admin';
    }


    public function getUsersByRole()
    {
        if (!$this->isAdmin()) {
            return $this->failForbidden('Akses Ditolak');
        }

        $role = $this->request->getGet('role');
        if (!$role) {
            return $this->fail('Parameter role diperlukan', 400);
        }

        $users = $this->userModel->where('role', $role)->findAll();

        return $this->respond([
            'status' => 'success',
            'data'   => $users
        ]);
    }


    public function addUser()
    {
        if (!$this->isAdmin()) {
            return $this->failForbidden('Akses Ditolak: Anda bukan admin');
        }

        $json = $this->request->getJSON(true);

        $rules = [
            'name'     => 'required|min_length[3]',
            'email'    => 'required|valid_email|is_unique[users.email]',
            'password' => 'required|min_length[6]',
            'role'     => 'required|in_list[admin,pengguna,kepala_proyek,mandor]',
        ];

        if (!$this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $data = [
            'name'     => $json['name'],
            'email'    => $json['email'],
            'password' => password_hash($json['password'], PASSWORD_DEFAULT),
            'role'     => $json['role'],
            'phone'    => $json['phone'] ?? null,
        ];

        if ($this->userModel->insert($data)) {
            return $this->respondCreated([
                'status'  => 'success',
                'message' => 'User berhasil ditambahkan',
                'data'    => ['user' => $this->userModel->find($this->userModel->getInsertID())]
            ]);
        }

        return $this->failServerError('Gagal menyimpan user');
    }


    public function getUsers()
    {
        if (!$this->isAdmin()) {
            return $this->failForbidden('Akses Ditolak');
        }

        return $this->respond([
            'status' => 'success',
            'data'   => $this->userModel->findAll()
        ]);
    }


    public function deleteUser($id = null)
    {
        if (!$this->isAdmin()) {
            return $this->failForbidden('Akses Ditolak');
        }

        $currentUser = $this->getCurrentUser();
        if ($currentUser && $currentUser->id == $id) {
            return $this->failForbidden('Tidak bisa menghapus akun sendiri');
        }

        if ($this->userModel->delete($id)) {
            return $this->respondDeleted(['status' => 'success', 'message' => 'User dihapus']);
        }

        return $this->failServerError('Gagal menghapus user');
    }
}