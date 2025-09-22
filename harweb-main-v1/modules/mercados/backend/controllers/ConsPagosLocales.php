<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsPagosLocalesController extends Controller
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
                case 'getSecciones':
                    $response['data'] = DB::select('SELECT * FROM get_secciones()');
                    $response['success'] = true;
                    break;
                case 'getMercadosByOficina':
                    $oficina = $params['oficina'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM get_mercados_by_oficina(?)', [$oficina]);
                    $response['success'] = true;
                    break;
                case 'getCajasByOficina':
                    $oficina = $params['oficina'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM get_cajas_by_oficina(?)', [$oficina]);
                    $response['success'] = true;
                    break;
                case 'buscarPagosPorLocal':
                    $result = DB::select('SELECT * FROM buscar_pagos_locales_por_local(?,?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'] ?? null,
                        $params['num_mercado'] ?? null,
                        $params['categoria'] ?? null,
                        $params['seccion'] ?? null,
                        $params['local'] ?? null,
                        $params['letra_local'] ?? null,
                        $params['bloque'] ?? null,
                        $params['orden'] ?? 'a.oficina,a.num_mercado,a.categoria,a.seccion,a.local,a.letra_local,a.bloque,b.axo,b.periodo',
                        $params['limit'] ?? 100,
                        $params['offset'] ?? 0
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'buscarPagosPorFecha':
                    $result = DB::select('SELECT * FROM buscar_pagos_locales_por_fecha(?,?,?,?,?,?,?,?)', [
                        $params['fecha_pago'] ?? null,
                        $params['oficina_pago'] ?? null,
                        $params['caja_pago'] ?? null,
                        $params['operacion_pago'] ?? null,
                        $params['orden'] ?? 'b.fecha_pago,b.oficina_pago,b.caja_pago,b.operacion_pago,a.oficina,a.num_mercado,a.categoria,a.seccion,a.local,a.letra_local,a.bloque,b.axo,b.periodo',
                        $params['limit'] ?? 100,
                        $params['offset'] ?? 0,
                        $params['usuario_id'] ?? null
                    ]);
                    $response['data'] = $result;
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
