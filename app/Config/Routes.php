<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// API Routes
$routes->group('api', ['namespace' => 'App\Controllers\Api'], function($routes) {
    

    //public
    $routes->post('login', 'AuthController::login');
    $routes->post('register', 'AuthController::register');
    
    //private routes
    $routes->group('', ['filter' => 'jwtauth'], function($routes) {
        
        //testing
        $routes->get('test/jwt', 'TestController::testJwt');
        
        //user profile
        $routes->get('profile', 'AuthController::profile');
        $routes->post('profile/update', 'AuthController::updateProfile');
        $routes->post('profile/change-password', 'AuthController::changePassword');
        
        //user management
        $routes->post('admin/users', 'AdminController::addUser');
        $routes->post('admin/users/raw', 'AdminController::addUserRaw');
        $routes->get('admin/users', 'AdminController::getUsers');
        $routes->put('admin/users/(:num)', 'AdminController::updateUser/$1');
        $routes->delete('admin/users/(:num)', 'AdminController::deleteUser/$1');
        $routes->get('admin/users/by-role', 'AdminController::getUsersByRole');
        
        //project
        $routes->get('projects', 'ProjectController::index');
        $routes->post('projects', 'ProjectController::create');
        $routes->get('projects/(:num)', 'ProjectController::show/$1');
        $routes->put('projects/(:num)', 'ProjectController::update/$1');
        $routes->delete('projects/(:num)', 'ProjectController::delete/$1');
        
        //report
        $routes->post('reports', 'ReportController::create');
        $routes->get('reports/project/(:num)', 'ReportController::getByProject/$1');
        $routes->get('reports/(:num)', 'ReportController::show/$1');
        $routes->put('reports/(:num)/verify', 'ReportController::verify/$1');
        
        //material
        $routes->post('materials', 'MaterialController::create');
        $routes->get('materials/project/(:num)', 'MaterialController::getByProject/$1');
        $routes->get('materials/(:num)', 'MaterialController::show/$1');
        $routes->put('materials/(:num)/approve', 'MaterialController::approve/$1');
        $routes->put('materials/(:num)/reject', 'MaterialController::reject/$1');
    });
});

//public
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