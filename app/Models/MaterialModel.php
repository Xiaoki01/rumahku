<?php

namespace App\Models;

use CodeIgniter\Model;

class MaterialModel extends Model
{
    protected $table = 'material_requests';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'project_id', 'mandor_id', 'material_name', 'quantity', 
        'unit', 'description', 'status', 'approved_by', 'approved_at'
    ];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
    
    public function getMaterialsWithRelations($where = [])
    {
        $builder = $this->db->table($this->table);
        $builder->select('material_requests.*, 
                         projects.name as project_name,
                         u1.name as mandor_name,
                         u2.name as approved_by_name');
        $builder->join('projects', 'projects.id = material_requests.project_id');
        $builder->join('users u1', 'u1.id = material_requests.mandor_id');
        $builder->join('users u2', 'u2.id = material_requests.approved_by', 'left');
        
        if (!empty($where)) {
            $builder->where($where);
        }
        
        $builder->orderBy('material_requests.created_at', 'DESC');
        
        return $builder->get()->getResultArray();
    }
    
    public function getMaterialWithRelations($id)
    {
        $builder = $this->db->table($this->table);
        $builder->select('material_requests.*, 
                         projects.name as project_name,
                         u1.name as mandor_name,
                         u2.name as approved_by_name');
        $builder->join('projects', 'projects.id = material_requests.project_id');
        $builder->join('users u1', 'u1.id = material_requests.mandor_id');
        $builder->join('users u2', 'u2.id = material_requests.approved_by', 'left');
        $builder->where('material_requests.id', $id);
        
        return $builder->get()->getRowArray();
    }
}