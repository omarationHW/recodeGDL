<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for uDM_Procesos.
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];

        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'get_tipo_aseo':
                    $tipo = $params['tipo'] ?? 0;
                    $result = DB::select('SELECT * FROM sp_get_tipo_aseo(?)', [$tipo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_dia_limite':
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_dia_limite(?)', [$mes]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_contratos_count':
                    $ctrol = $params['ctrol'] ?? null;
                    $status = $params['status'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_contratos_count(?, ?)', [$ctrol, $status]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_pagos_summary':
                    $ctrol_a = $params['ctrol_a'] ?? null;
                    $fecha = $params['fecha'] ?? null;
                    $operacion = $params['operacion'] ?? null;
                    $status = $params['status'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_pagos_summary(?, ?, ?, ?)', [$ctrol_a, $fecha, $operacion, $status]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'procesos_dashboard':
                    // Lógica de dashboard principal (simula AfterScroll)
                    $ctrol_a = $params['ctrol_a'] ?? null;
                    $fecha1 = $params['fecha1'] ?? null;
                    $fecha2 = $params['fecha2'] ?? null;
                    $result = DB::select('SELECT * FROM sp_procesos_dashboard(?, ?, ?)', [$ctrol_a, $fecha1, $fecha2]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
