<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones vía eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($operation) {
                case 'getSinLigarPagos':
                    $fecha1 = $params['fecha1'] ?? null;
                    $fecha2 = $params['fecha2'] ?? null;
                    if (!$fecha1 || !$fecha2) {
                        throw new \Exception('Parámetros fecha1 y fecha2 son requeridos');
                    }
                    $result = DB::select('SELECT * FROM report_sinligar_pagos(:fecha1, :fecha2)', [
                        'fecha1' => $fecha1,
                        'fecha2' => $fecha2
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    throw new \Exception('Operación no soportada: ' . $operation);
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['success'] = false;
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
