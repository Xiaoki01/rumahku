<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// API Routes
$routes->group('api', ['namespace' => 'App\Controllers\Api'], function($routes) {
    
    // Public Auth routes (NO JWT required)
    $routes->post('login', 'AuthController::login');
    $routes->post('register', 'AuthController::register');
    
    // Protected routes dengan JWT filter
    $routes->group('', ['filter' => 'jwtauth'], function($routes) {
        
        // User profile
        $routes->get('profile', 'AuthController::profile');
        $routes->post('profile/update', 'AuthController::updateProfile');
        $routes->post('profile/change-password', 'AuthController::changePassword');
        
        // Projects
        $routes->get('projects', 'ProjectController::index');
        $routes->post('projects', 'ProjectController::create');
        $routes->get('projects/(:num)', 'ProjectController::show/$1');
        $routes->put('projects/(:num)', 'ProjectController::update/$1');
        $routes->delete('projects/(:num)', 'ProjectController::delete/$1');
        
        // Reports
        $routes->post('reports', 'ReportController::create');
        $routes->get('reports/project/(:num)', 'ReportController::getByProject/$1');
        $routes->get('reports/(:num)', 'ReportController::show/$1');
        $routes->put('reports/(:num)/verify', 'ReportController::verify/$1');
        
        // Material Requests
        $routes->post('materials', 'MaterialController::create');
        $routes->get('materials/project/(:num)', 'MaterialController::getByProject/$1');
        $routes->get('materials/(:num)', 'MaterialController::show/$1');
        $routes->put('materials/(:num)/approve', 'MaterialController::approve/$1');
        $routes->put('materials/(:num)/reject', 'MaterialController::reject/$1');
    });
});

// ✅ TAMBAHKAN: Public route untuk serve images (di luar API group)
// Ini memungkinkan Image.network() di Flutter bisa akses tanpa JWT
$routes->get('uploads/reports/(:any)', function($filename) {
    $filepath = FCPATH . 'uploads/reports/' . $filename;
    
    if (file_exists($filepath)) {
        header('Content-Type: ' . mime_content_type($filepath));
        header('Content-Length: ' . filesize($filepath));
        readfile($filepath);
        exit;
    } else {
        throw \CodeIgniter\Exceptions\PageNotFoundException::forPageNotFound();
    }
});