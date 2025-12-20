<?php

namespace App\Models;

use CodeIgniter\Model;

class ReportModel extends Model
{
    protected $table = 'reports';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $allowedFields = [
        'project_id',
        'mandor_id',
        'date',
        'progress',
        'description',
        'kendala',
        'jumlah_tenaga_kerja',
        'photo',
        'status',
        'verified_by',
        'verified_at'
    ];
    
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    private function addPhotoUrl(&$data)
    {
        $baseUrl = base_url();
        
        if (!empty($data['photo'])) {
            $data['photo_url'] = $baseUrl . 'uploads/reports/' . $data['photo'];
        } else {
            $data['photo_url'] = null;
        }
    }
    
    public function getReportWithRelations($id)
    {
        $report = $this->select('
                reports.*,
                projects.name as project_name,
                mandor.name as mandor_name,
                verifier.name as verified_by_name
            ')
            ->join('projects', 'projects.id = reports.project_id', 'left')
            ->join('users as mandor', 'mandor.id = reports.mandor_id', 'left')
            ->join('users as verifier', 'verifier.id = reports.verified_by', 'left')
            ->find($id);
        
        if ($report) {
            $this->addPhotoUrl($report);
        }
        
        return $report;
    }
    
    public function getReportsWithRelations($conditions = [])
    {
        $builder = $this->select('
                reports.*,
                projects.name as project_name,
                mandor.name as mandor_name,
                verifier.name as verified_by_name
            ')
            ->join('projects', 'projects.id = reports.project_id', 'left')
            ->join('users as mandor', 'mandor.id = reports.mandor_id', 'left')
            ->join('users as verifier', 'verifier.id = reports.verified_by', 'left')
            ->orderBy('reports.date', 'DESC');
        
        if (!empty($conditions)) {
            $builder->where($conditions);
        }
        
        $reports = $builder->findAll();
        
        foreach ($reports as &$report) {
            $this->addPhotoUrl($report);
        }
        
        return $reports;
    }
}