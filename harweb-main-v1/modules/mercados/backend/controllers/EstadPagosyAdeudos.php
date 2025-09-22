<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EstadPagosyAdeudosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario EstadPagosyAdeudos
     * Entrada: eRequest con action y params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $data = DB::select('SELECT * FROM get_recaudadoras()');
                    $response = [
                        'status' => 'ok',
                        'data' => $data,
                        'message' => 'Listado de recaudadoras obtenido'
                    ];
                    break;
                case 'getMercadosByRecaudadora':
                    $rec = $params['rec'] ?? null;
                    $data = DB::select('SELECT * FROM get_mercados_by_recaudadora(?)', [$rec]);
                    $response = [
                        'status' => 'ok',
                        'data' => $data,
                        'message' => 'Listado de mercados obtenido'
                    ];
                    break;
                case 'getEstadisticaPagosyAdeudos':
                    $rec = $params['rec'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $fecdsd = $params['fecdsd'] ?? null;
                    $fechst = $params['fechst'] ?? null;
                    $data = DB::select('SELECT * FROM get_estadistica_pagosyadeudos(?,?,?,?,?)', [$rec, $axo, $mes, $fecdsd, $fechst]);
                    $response = [
                        'status' => 'ok',
                        'data' => $data,
                        'message' => 'Estadística obtenida'
                    ];
                    break;
                case 'getMercadoDetalle':
                    $rec = $params['rec'] ?? null;
                    $mercado = $params['mercado'] ?? null;
                    $data = DB::select('SELECT * FROM get_mercado_detalle(?, ?)', [$rec, $mercado]);
                    $response = [
                        'status' => 'ok',
                        'data' => $data,
                        'message' => 'Detalle de mercado obtenido'
                    ];
                    break;
                case 'exportEstadisticaPagosyAdeudos':
                    // Lógica para exportar a Excel/PDF (puede ser implementada con un job o paquete externo)
                    $response = [
                        'status' => 'ok',
                        'data' => null,
                        'message' => 'Exportación en proceso (no implementado en este ejemplo)'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json(['eResponse' => $response]);
    }
}
