<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RptPagosDesarrolloController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario RptPagosDesarrollo
     * Entrada: {
     *   "eRequest": {
     *     "action": "getReport",
     *     "params": {
     *        "fecdesde": "2024-01-01",
     *        "fechasta": "2024-12-31"
     *     }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [];

        switch ($action) {
            case 'getReport':
                $fecdesde = $params['fecdesde'] ?? null;
                $fechasta = $params['fechasta'] ?? null;
                if (!$fecdesde || !$fechasta) {
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Parámetros fecdesde y fechasta son requeridos.'
                    ]]);
                }
                $result = DB::select('SELECT * FROM rpt_pagos_desarrollo($1, $2)', [$fecdesde, $fechasta]);
                $eResponse = [
                    'success' => true,
                    'data' => $result
                ];
                break;
            case 'getFondos':
                $fondos = DB::select('SELECT * FROM cat_fondos()');
                $eResponse = [
                    'success' => true,
                    'data' => $fondos
                ];
                break;
            default:
                $eResponse = [
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ];
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
