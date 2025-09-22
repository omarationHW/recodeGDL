<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RptPagosContratosDecsDev':
                    // Expected param: colonia (int)
                    $colonia = isset($params['colonia']) ? (int)$params['colonia'] : null;
                    if ($colonia === null) {
                        $eResponse['message'] = 'Parámetro colonia es requerido.';
                        break;
                    }
                    $result = DB::select('SELECT * FROM rpt_pagos_contratos_descs_dev(:colonia)', [
                        'colonia' => $colonia
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
