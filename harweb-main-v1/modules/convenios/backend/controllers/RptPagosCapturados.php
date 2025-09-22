<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RptPagosCapturadosController extends Controller
{
    /**
     * Handle unified API requests for RptPagosCapturados.
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'getPagosCapturados':
                    $subtipo = $eRequest['params']['subtipo'] ?? null;
                    if (!$subtipo) {
                        throw new \Exception('Parámetro subtipo requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_rpt_pagos_capturados(?)', [$subtipo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getPagosCapturadosResumen':
                    $subtipo = $eRequest['params']['subtipo'] ?? null;
                    if (!$subtipo) {
                        throw new \Exception('Parámetro subtipo requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_rpt_pagos_capturados_resumen(?)', [$subtipo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
