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
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'buscar_pagos_diversos':
                    $result = DB::select('SELECT * FROM pagosdiv_buscar(:fecha, :recaud, :caja, :folio, :contribuyente)', [
                        'fecha' => $params['fecha'] ?? null,
                        'recaud' => $params['recaud'] ?? null,
                        'caja' => $params['caja'] ?? null,
                        'folio' => $params['folio'] ?? null,
                        'contribuyente' => $params['contribuyente'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'detalle_pago_diverso':
                    $cvepago = $params['cvepago'] ?? null;
                    if (!$cvepago) {
                        throw new \Exception('cvepago es requerido');
                    }
                    $diversos = DB::select('SELECT * FROM pago_diversos WHERE cvepago = ?', [$cvepago]);
                    $auditoria = DB::select('SELECT * FROM auditoria WHERE cvepago = ?', [$cvepago]);
                    $pagoscan = DB::select('SELECT * FROM pagoscan WHERE cvepago = ?', [$cvepago]);
                    $response['success'] = true;
                    $response['data'] = [
                        'diversos' => $diversos,
                        'auditoria' => $auditoria,
                        'pagoscan' => $pagoscan
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
