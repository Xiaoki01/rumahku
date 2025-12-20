<?php

namespace App\Models;

use CodeIgniter\Model;

class ProjectModel extends Model
{
    protected $table = 'projects';
    protected $primaryKey = 'id';
    protected $allowedFields = [
        'name', 'description', 'location', 'start_date', 'end_date', 
        'budget', 'status', 'user_id', 'kepala_proyek_id', 'mandor_id'
    ];
    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';
    
    public function getProjectsWithUsers($where = [])
    {
        $builder = $this->db->table($this->table);
        $builder->select('projects.*, 
                         u1.name as owner_name, u1.email as owner_email,
                         u2.name as kepala_proyek_name, u2.email as kepala_proyek_email,
                         u3.name as mandor_name, u3.email as mandor_email');
        $builder->join('users u1', 'u1.id = projects.user_id');
        $builder->join('users u2', 'u2.id = projects.kepala_proyek_id');
        $builder->join('users u3', 'u3.id = projects.mandor_id');
        
        if (!empty($where)) {
            $builder->where($where);
        }
        
        return $builder->get()->getResultArray();
    }
    
    public function getProjectWithUsers($id)
    {
        $builder = $this->db->table($this->table);
        $builder->select('projects.*, 
                         u1.name as owner_name, u1.email as owner_email, u1.phone as owner_phone,
                         u2.name as kepala_proyek_name, u2.email as kepala_proyek_email, u2.phone as kepala_proyek_phone,
                         u3.name as mandor_name, u3.email as mandor_email, u3.phone as mandor_phone');
        $builder->join('users u1', 'u1.id = projects.user_id');
        $builder->join('users u2', 'u2.id = projects.kepala_proyek_id');
        $builder->join('users u3', 'u3.id = projects.mandor_id');
        $builder->where('projects.id', $id);
        
        return $builder->get()->getRowArray();
    }
}