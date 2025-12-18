<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\ReportModel;
use App\Models\ProjectModel;
use CodeIgniter\API\ResponseTrait;

class ReportController extends BaseController
{
    use ResponseTrait;

    protected $reportModel;
    protected $projectModel;
    
    public function __construct()
    {
        $this->reportModel = new ReportModel();
        $this->projectModel = new ProjectModel();
    }
    
    /**
     * Create report (Mandor only) - WITH PROPER PHOTO UPLOAD
     * POST /api/reports
     */
    public function create()
    {
        $user = $this->request->userData ?? null;
        
        if (!$user) {
            return $this->failUnauthorized('Token invalid atau sesi berakhir');
        }

        if ($user->role !== 'mandor') {
            return $this->failForbidden('Hanya mandor yang dapat membuat laporan');
        }
        
        $rules = [
            'project_id'          => 'required|numeric',
            'date'                => 'required|valid_date',
            'progress'            => 'required|decimal',
            'description'         => 'required|min_length[10]',
            'jumlah_tenaga_kerja' => 'required|numeric',
            'photo'               => 'if_exist|uploaded[photo]|max_size[photo,2048]|is_image[photo]|mime_in[photo,image/jpg,image/jpeg,image/png]'
        ];
        
        if (!$this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }
        
        // Cek akses ke project
        $project = $this->projectModel->find($this->request->getVar('project_id'));
        if (!$project) {
            return $this->failNotFound('Project tidak ditemukan');
        }

        if ($project['mandor_id'] != $user->id) {
            return $this->failForbidden('Anda bukan mandor di project ini');
        }
        
        // Handle photo upload
        $photoPath = null;
        $photo = $this->request->getFile('photo');
        
        if ($photo && $photo->isValid() && !$photo->hasMoved()) {
            // Validasi tambahan
            if (!in_array($photo->getMimeType(), ['image/jpeg', 'image/jpg', 'image/png'])) {
                return $this->failValidationErrors('File harus berupa gambar (jpg, jpeg, png)');
            }
            
            $newName = $photo->getRandomName();
            $uploadPath = FCPATH . 'uploads/reports/';
            
            // Buat folder jika belum ada
            if (!is_dir($uploadPath)) {
                mkdir($uploadPath, 0755, true);
            }
            
            // Move file
            if ($photo->move($uploadPath, $newName)) {
                $photoPath = $newName;
            } else {
                return $this->failServerError('Gagal mengupload foto');
            }
        }
        
        $data = [
            'project_id'          => $this->request->getVar('project_id'),
            'mandor_id'           => $user->id,
            'date'                => $this->request->getVar('date'),
            'progress'            => $this->request->getVar('progress'),
            'description'         => $this->request->getVar('description'),
            'kendala'             => $this->request->getVar('kendala'),
            'jumlah_tenaga_kerja' => $this->request->getVar('jumlah_tenaga_kerja'),
            'photo'               => $photoPath,
            'status'              => 'menunggu'
        ];
        
        if ($this->reportModel->insert($data)) {
            $reportId = $this->reportModel->getInsertID();
            $report = $this->reportModel->getReportWithRelations($reportId);
            
            return $this->respondCreated([
                'status' => 'success',
                'message' => 'Laporan berhasil dibuat',
                'data' => $report
            ]);
        }
        
        return $this->failServerError('Gagal membuat laporan');
    }
    
    /**
     * Get reports by project
     * GET /api/reports/project/{project_id}
     */
    public function getByProject($projectId)
    {
        $user = $this->request->userData ?? null;
        if (!$user) return $this->failUnauthorized();
        
        $project = $this->projectModel->find($projectId);
        if (!$project) {
            return $this->failNotFound('Project tidak ditemukan');
        }
        
        // Check access
        if ($user->role !== 'admin') {
            $hasAccess = ($project['user_id'] == $user->id) ||
                         ($project['kepala_proyek_id'] == $user->id) ||
                         ($project['mandor_id'] == $user->id);
            
            if (!$hasAccess) {
                return $this->failForbidden('Akses ditolak');
            }
        }
        
        $reports = $this->reportModel->getReportsWithRelations(['reports.project_id' => $projectId]);
        
        return $this->respond([
            'status' => 'success',
            'data' => $reports
        ]);
    }
    
    /**
     * Get single report
     * GET /api/reports/{id}
     */
    public function show($id)
    {
        $report = $this->reportModel->getReportWithRelations($id);
        
        if (!$report) {
            return $this->failNotFound('Laporan tidak ditemukan');
        }
        
        return $this->respond([
            'status' => 'success',
            'data' => $report
        ]);
    }
    
    /**
     * Verify report (Kepala Proyek only)
     * PUT /api/reports/{id}/verify
     */
    public function verify($id)
    {
        $user = $this->request->userData ?? null;
        if (!$user) return $this->failUnauthorized();
        
        if ($user->role !== 'kepala_proyek') {
            return $this->failForbidden('Hanya kepala proyek yang dapat memverifikasi laporan');
        }
        
        $report = $this->reportModel->find($id);
        if (!$report) {
            return $this->failNotFound('Laporan tidak ditemukan');
        }
        
        $project = $this->projectModel->find($report['project_id']);
        
        if (!$project) return $this->failNotFound('Project tidak ditemukan');

        if ($project['kepala_proyek_id'] != $user->id) {
            return $this->failForbidden('Anda bukan Kepala Proyek di project ini');
        }
        
        $data = [
            'status'      => 'diverifikasi',
            'verified_by' => $user->id,
            'verified_at' => date('Y-m-d H:i:s')
        ];
        
        if ($this->reportModel->update($id, $data)) {
            $updated = $this->reportModel->getReportWithRelations($id);
            
            return $this->respond([
                'status' => 'success',
                'message' => 'Laporan berhasil diverifikasi',
                'data' => $updated
            ]);
        }
        
        return $this->failServerError('Gagal memverifikasi laporan');
    }
}