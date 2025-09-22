<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PagosLocGrlController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                    $response['data'] = DB::select('SELECT * FROM get_recaudadoras()');
                    $response['success'] = true;
                    break;
                case 'getMercadosByRecaudadora':
                    $recId = $params['recaudadora_id'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM get_mercados_by_recaudadora(?)', [$recId]);
                    $response['success'] = true;
                    break;
                case 'getPagosLocGrl':
                    $recId = $params['recaudadora_id'] ?? null;
                    $mercadoId = $params['mercado_id'] ?? null;
                    $fechaDesde = $params['fecha_desde'] ?? null;
                    $fechaHasta = $params['fecha_hasta'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM get_pagos_loc_grl(?,?,?,?)', [$recId, $mercadoId, $fechaDesde, $fechaHasta]);
                    $response['success'] = true;
                    break;
                case 'exportPagosLocGrlExcel':
                    // Implementación de exportación a Excel (puede ser un job o retornar URL de descarga)
                    // Aquí solo se simula la respuesta
                    $response['data'] = [
                        'url' => '/exports/pagos_loc_grl.xlsx'
                    ];
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
