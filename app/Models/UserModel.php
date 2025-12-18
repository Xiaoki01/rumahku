<?php

namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table = 'users';
    protected $primaryKey = 'id';
    protected $allowedFields = ['name', 'email', 'password', 'role', 'phone'];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
    
    protected $validationRules = [
        'name'     => 'required|min_length[3]',
        'email'    => 'required|valid_email|is_unique[users.email]',
        'password' => 'required|min_length[6]',
        'role'     => 'required|in_list[admin,pengguna,kepala_proyek,mandor]'
    ];
    
    protected $validationMessages = [
        'email' => [
            'is_unique' => 'Email sudah terdaftar'
        ]
    ];
    
    // Jangan return password
    protected $afterFind = ['removePassword'];
    
    protected function removePassword(array $data)
    {
        if (isset($data['data'])) {
            if (is_array($data['data'])) {
                foreach ($data['data'] as &$row) {
                    if (isset($row['password'])) {
                        unset($row['password']);
                    }
                }
            } else {
                if (isset($data['data']->password)) {
                    unset($data['data']->password);
                }
            }
        }
        return $data;
    }
}