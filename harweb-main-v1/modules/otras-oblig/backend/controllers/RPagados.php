<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern).
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];

        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => '',
            'errors' => null
        ];

        try {
            switch ($operation) {
                case 'getPagadosByControl':
                    $control = $params['p_Control'] ?? null;
                    if (!$control) {
                        throw new \Exception('Parámetro p_Control requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_rpagados_get_pagados_by_control(?)', [$control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = 'Error en la operación';
            $eResponse['errors'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
