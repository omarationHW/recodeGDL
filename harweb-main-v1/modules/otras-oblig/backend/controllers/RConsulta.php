<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($action) {
                case 'get_concesion_by_control':
                    $control = $params['control'] ?? null;
                    $result = DB::select('SELECT * FROM get_concesion_by_control(?)', [$control]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_adeudos_by_concesion':
                    $id_34_datos = $params['id_34_datos'] ?? null;
                    $aso = $params['aso'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('SELECT * FROM get_adeudos_by_concesion(?,?,?)', [$id_34_datos, $aso, $mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_totales_by_concesion':
                    $id_34_datos = $params['id_34_datos'] ?? null;
                    $aso = $params['aso'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('SELECT * FROM get_totales_by_concesion(?,?,?)', [$id_34_datos, $aso, $mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_pagados_by_concesion':
                    $id_34_datos = $params['id_34_datos'] ?? null;
                    $result = DB::select('SELECT * FROM get_pagados_by_concesion(?)', [$id_34_datos]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_fecha_limite':
                    $result = DB::select('SELECT * FROM get_fecha_limite()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['error'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['error'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
