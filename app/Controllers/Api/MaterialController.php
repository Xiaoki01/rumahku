<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\MaterialModel;
use App\Models\ProjectModel;
use CodeIgniter\API\ResponseTrait;

class MaterialController extends BaseController
{
    use ResponseTrait;

    protected $materialModel;
    protected $projectModel;
    
    public function __construct()
    {
        $this->materialModel = new MaterialModel();
        $this->projectModel = new ProjectModel();
    }
    
    public function create()
    {
        $user = $this->request->userData ?? null;
        
        if (!$user) {
            return $this->failUnauthorized('Token invalid atau sesi berakhir');
        }

        if ($user->role !== 'mandor') {
            return $this->failForbidden('Hanya mandor yang dapat request material');
        }
        
        $rules = [
            'project_id'    => 'required|numeric',
            'material_name' => 'required|min_length[3]',
            'quantity'      => 'required|decimal',
            'unit'          => 'required'
        ];
        
        if (!$this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }
        
        $project = $this->projectModel->find($this->request->getVar('project_id'));
        
        if (!$project) {
            return $this->failNotFound('Project tidak ditemukan');
        }
        
        if ($project['mandor_id'] != $user->id) {
            return $this->failForbidden('Anda bukan mandor dari project ini');
        }
        
        $data = [
            'project_id'    => $this->request->getVar('project_id'),
            'mandor_id'     => $user->id,
            'material_name' => $this->request->getVar('material_name'),
            'quantity'      => $this->request->getVar('quantity'),
            'unit'          => $this->request->getVar('unit'),
            'description'   => $this->request->getVar('description'),
            'status'        => 'pending'
        ];
        
        if ($this->materialModel->insert($data)) {
            $materialId = $this->materialModel->getInsertID();
            
            $material = $this->materialModel->getMaterialWithRelations($materialId); 
            
            return $this->respondCreated([
                'status' => 'success',
                'message' => 'Request material berhasil dibuat',
                'data' => $material
            ]);
        }
        
        return $this->failServerError('Gagal membuat request material');
    }

    public function getByProject($projectId)
    {
        $user = $this->request->userData ?? null;
        if (!$user) return $this->failUnauthorized();
        
        $project = $this->projectModel->find($projectId);
        if (!$project) {
            return $this->failNotFound('Project tidak ditemukan');
        }
        
        if ($user->role !== 'admin') {
            $hasAccess = ($project['user_id'] == $user->id) ||
                         ($project['kepala_proyek_id'] == $user->id) ||
                         ($project['mandor_id'] == $user->id);
            
            if (!$hasAccess) {
                return $this->failForbidden('Akses ditolak ke project ini');
            }
        }
        
        $materials = $this->materialModel->getMaterialsWithRelations(['material_requests.project_id' => $projectId]);
        
        return $this->respond([
            'status' => 'success',
            'data' => $materials
        ]);
    }

    public function show($id)
    {
        $material = $this->materialModel->getMaterialWithRelations($id);
        
        if (!$material) {
            return $this->failNotFound('Request material tidak ditemukan');
        }
        
        return $this->respond([
            'status' => 'success',
            'data' => $material
        ]);
    }

    public function approve($id)
    {
        $user = $this->request->userData ?? null;
        if (!$user) return $this->failUnauthorized();
        
        if (!in_array($user->role, ['kepala_proyek', 'admin'])) {
            return $this->failForbidden('Akses ditolak');
        }
        
        $material = $this->materialModel->find($id);
        if (!$material) {
            return $this->failNotFound('Request material tidak ditemukan');
        }
        
        if ($user->role === 'kepala_proyek') {
            $project = $this->projectModel->find($material['project_id']);
            if ($project['kepala_proyek_id'] != $user->id) {
                return $this->failForbidden('Anda bukan Kepala Proyek di project ini');
            }
        }
        
        $data = [
            'status'      => 'approved',
            'approved_by' => $user->id,
            'approved_at' => date('Y-m-d H:i:s')
        ];
        
        if ($this->materialModel->update($id, $data)) {
            $updated = $this->materialModel->getMaterialWithRelations($id);
            return $this->respond([
                'status' => 'success',
                'message' => 'Request material berhasil disetujui',
                'data' => $updated
            ]);
        }
        
        return $this->failServerError('Gagal menyetujui request material');
    }
    
    public function reject($id)
    {
        $user = $this->request->userData ?? null;
        if (!$user) return $this->failUnauthorized();
        
        if (!in_array($user->role, ['kepala_proyek', 'admin'])) {
            return $this->failForbidden('Akses ditolak');
        }
        
        $material = $this->materialModel->find($id);
        if (!$material) {
            return $this->failNotFound('Request material tidak ditemukan');
        }
        
        $data = [
            'status'      => 'rejected',
            'approved_by' => $user->id,
            'approved_at' => date('Y-m-d H:i:s')
        ];
        
        if ($this->materialModel->update($id, $data)) {
            $updated = $this->materialModel->getMaterialWithRelations($id);
            return $this->respond([
                'status' => 'success',
                'message' => 'Request material ditolak',
                'data' => $updated
            ]);
        }
        
        return $this->failServerError('Gagal menolak request material');
    }
}