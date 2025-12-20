<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class Cors implements FilterInterface
{

    public function before(RequestInterface $request, $arguments = null)
    {
        header('Access-Control-Allow-Origin: *');

        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');

        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept');

        if ($request->getMethod() === 'options') {
            $response = service('response');
            $response->setStatusCode(200);

            return $response;
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
    }
}
