<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EstadPagosyAdeudosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'getRecaudadoras':
                    $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'getMercadosByRecaudadora':
                    $id_rec = $params['id_rec'] ?? null;
                    $data = DB::select('SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = ? AND tipo_emision <> ? ORDER BY num_mercado_nvo', [$id_rec, 'B']);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'getEstadisticaPagosyAdeudos':
                    $id_rec = $params['id_rec'];
                    $axo = $params['axo'];
                    $mes = $params['mes'];
                    $fec3 = $params['fec3'];
                    $fec4 = $params['fec4'];
                    $result = DB::select('CALL sp_estad_pagosyadeudos(?, ?, ?, ?, ?)', [$id_rec, $axo, $mes, $fec3, $fec4]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getResumenPorMercado':
                    $id_rec = $params['id_rec'];
                    $axo = $params['axo'];
                    $mes = $params['mes'];
                    $fec3 = $params['fec3'];
                    $fec4 = $params['fec4'];
                    $result = DB::select('CALL sp_estad_pagosyadeudos_resumen(?, ?, ?, ?, ?)', [$id_rec, $axo, $mes, $fec3, $fec4]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
