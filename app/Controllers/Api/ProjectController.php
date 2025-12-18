<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\ProjectModel;

class ProjectController extends BaseController
{
    protected $projectModel;
    
    public function __construct()
    {
        $this->projectModel = new ProjectModel();
    }
    
    /**
     * Get all projects berdasarkan role
     * GET /api/projects
     */
    public function index()
    {
        // PERBAIKAN: Gunakan 'userData' sesuai dengan AuthController sebelumnya
        $user = $this->request->userData ?? null;

        if (!$user) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Token invalid atau sesi berakhir'
            ])->setStatusCode(401);
        }
        
        $where = [];
        
        // Filter berdasarkan role
        switch ($user->role) {
            case 'admin':
                // Admin lihat semua
                break;
            case 'pengguna':
                $where['projects.user_id'] = $user->id;
                break;
            case 'kepala_proyek':
                $where['projects.kepala_proyek_id'] = $user->id;
                break;
            case 'mandor':
                $where['projects.mandor_id'] = $user->id;
                break;
        }
        
        // Pastikan method ini ada di ProjectModel Anda
        $projects = $this->projectModel->getProjectsWithUsers($where);
        
        return $this->response->setJSON([
            'status' => 'success',
            'data' => $projects
        ]);
    }
    
    /**
     * Create new project
     * POST /api/projects
     */
    public function create()
    {
        // PERBAIKAN: Gunakan userData
        $user = $this->request->userData ?? null;
        
        if (!$user || $user->role !== 'admin') {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Akses ditolak'
            ])->setStatusCode(403);
        }
        
        $rules = [
            'name'             => 'required|min_length[3]',
            'start_date'       => 'required|valid_date',
            'user_id'          => 'required|numeric',
            'kepala_proyek_id' => 'required|numeric',
            'mandor_id'        => 'required|numeric'
        ];
        
        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Validasi gagal',
                'errors' => $this->validator->getErrors()
            ])->setStatusCode(400);
        }
        
        $data = [
            'name'             => $this->request->getVar('name'),
            'description'      => $this->request->getVar('description'),
            'location'         => $this->request->getVar('location'),
            'start_date'       => $this->request->getVar('start_date'),
            'end_date'         => $this->request->getVar('end_date'),
            'budget'           => $this->request->getVar('budget'),
            'status'           => $this->request->getVar('status') ?: 'planning',
            'user_id'          => $this->request->getVar('user_id'),
            'kepala_proyek_id' => $this->request->getVar('kepala_proyek_id'),
            'mandor_id'        => $this->request->getVar('mandor_id')
        ];
        
        if ($this->projectModel->insert($data)) {
            $projectId = $this->projectModel->getInsertID();
            $project = $this->projectModel->getProjectWithUsers($projectId);
            
            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Project berhasil dibuat',
                'data' => $project
            ])->setStatusCode(201);
        }
        
        return $this->response->setJSON([
            'status' => 'error',
            'message' => 'Gagal membuat project'
        ])->setStatusCode(500);
    }
    
    /**
     * Get single project
     * GET /api/projects/{id}
     */
    public function show($id)
    {
        // PERBAIKAN: Gunakan userData
        $user = $this->request->userData ?? null;
        
        if (!$user) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Unauthorized'])->setStatusCode(401);
        }

        $project = $this->projectModel->getProjectWithUsers($id);
        
        if (!$project) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Project tidak ditemukan'
            ])->setStatusCode(404);
        }
        
        // Check access
        if ($user->role !== 'admin') {
            // Pastikan array key sesuai dengan output model
            $hasAccess = ($project['user_id'] == $user->id) ||
                         ($project['kepala_proyek_id'] == $user->id) ||
                         ($project['mandor_id'] == $user->id);
            
            if (!$hasAccess) {
                return $this->response->setJSON([
                    'status' => 'error',
                    'message' => 'Akses ditolak'
                ])->setStatusCode(403);
            }
        }
        
        return $this->response->setJSON([
            'status' => 'success',
            'data' => $project
        ]);
    }
    
    /**
     * Update project
     * PUT /api/projects/{id}
     */
    public function update($id)
    {
        // PERBAIKAN: Gunakan userData
        $user = $this->request->userData ?? null;
        
        // Hanya admin dan kepala proyek yang bisa update
        if (!$user || !in_array($user->role, ['admin', 'kepala_proyek'])) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Akses ditolak'
            ])->setStatusCode(403);
        }
        
        $project = $this->projectModel->find($id);
        if (!$project) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Project tidak ditemukan'
            ])->setStatusCode(404);
        }
        
        $data = $this->request->getJSON(true);
        
        if ($this->projectModel->update($id, $data)) {
            $updated = $this->projectModel->getProjectWithUsers($id);
            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Project berhasil diupdate',
                'data' => $updated
            ]);
        }
        
        return $this->response->setJSON([
            'status' => 'error',
            'message' => 'Gagal update project'
        ])->setStatusCode(500);
    }
    
    /**
     * Delete project
     * DELETE /api/projects/{id}
     */
    public function delete($id)
    {
        // PERBAIKAN: Gunakan userData
        $user = $this->request->userData ?? null;
        
        // Hanya admin yang bisa delete
        if (!$user || $user->role !== 'admin') {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Akses ditolak'
            ])->setStatusCode(403);
        }
        
        if ($this->projectModel->delete($id)) {
            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Project berhasil dihapus'
            ]);
        }
        
        return $this->response->setJSON([
            'status' => 'error',
            'message' => 'Gagal menghapus project'
        ])->setStatusCode(500);
    }
}