<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'consultar_sanandres':
                    $result = DB::select('SELECT * FROM datos');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'consultar_sanandres_paginated':
                    $page = isset($params['page']) ? (int)$params['page'] : 1;
                    $perPage = isset($params['per_page']) ? (int)$params['per_page'] : 20;
                    $offset = ($page - 1) * $perPage;
                    $data = DB::select('SELECT * FROM datos ORDER BY id OFFSET ? LIMIT ?', [$offset, $perPage]);
                    $total = DB::selectOne('SELECT COUNT(*) as total FROM datos')->total;
                    $response['success'] = true;
                    $response['data'] = [
                        'items' => $data,
                        'total' => $total,
                        'page' => $page,
                        'per_page' => $perPage
                    ];
                    break;
                // Aquí se pueden agregar más acciones para otros formularios
                default:
                    $response['message'] = 'Acción no reconocida';
            }
        } catch (\Exception $e) {
            Log::error('ExecuteController error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
