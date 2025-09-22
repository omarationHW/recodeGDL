<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getDocumentos':
                    $response['data'] = DB::select('CALL sp_get_documentos(?,?,?,?,?,?,?,?)', [
                        $params['fecha_elaboracion'] ?? null,
                        $params['moneda'] ?? null,
                        $params['cta_mayor'] ?? null,
                        $params['cta_sub01'] ?? null,
                        $params['cta_sub02'] ?? null,
                        $params['cta_sub03'] ?? null,
                        $params['forma_pago'] ?? null,
                        $params['banco'] ?? null
                    ]);
                    $response['success'] = true;
                    break;
                case 'getCuentasTrans':
                    $response['data'] = DB::select('CALL sp_get_cuenta_trans(?,?,?,?,?)', [
                        $params['moneda'] ?? null,
                        $params['cta_mayor'] ?? null,
                        $params['cta_sub01'] ?? null,
                        $params['cta_sub02'] ?? null,
                        $params['cta_sub03'] ?? null
                    ]);
                    $response['success'] = true;
                    break;
                case 'getBancosPagadores':
                    $response['data'] = DB::select('CALL sp_get_bancos_pagadores()');
                    $response['success'] = true;
                    break;
                case 'generarTransferencia':
                    // params: tipo_doc, fecha, cuenta, documentos (array)
                    $result = DB::select('SELECT * FROM sp_generar_transferencia(?,?,?,?,?,?)', [
                        $params['tipo_doc'] ?? null,
                        $params['fecha'] ?? null,
                        $params['moneda'] ?? null,
                        $params['cta_mayor'] ?? null,
                        $params['cta_sub01'] ?? null,
                        $params['cta_sub02'] ?? null,
                        json_encode($params['documentos'] ?? [])
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}
