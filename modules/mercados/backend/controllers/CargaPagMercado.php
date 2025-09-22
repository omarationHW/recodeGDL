<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaPagMercadoController extends Controller
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
                case 'getMercados':
                    $response['data'] = DB::select('SELECT * FROM sp_get_mercados(?)', [$params['oficina'] ?? null]);
                    $response['success'] = true;
                    break;
                case 'getAdeudosLocal':
                    $response['data'] = DB::select('SELECT * FROM sp_get_adeudos_local(?,?,?,?,?)', [
                        $params['oficina'],
                        $params['mercado'],
                        $params['categoria'],
                        $params['seccion'],
                        $params['local']
                    ]);
                    $response['success'] = true;
                    break;
                case 'getIngresoOperacion':
                    $response['data'] = DB::select('SELECT * FROM sp_get_ingreso_operacion(?,?,?,?,?,?)', [
                        $params['fecha_ingreso'],
                        $params['oficina'],
                        $params['caja'],
                        $params['operacion'],
                        $params['oficina_mercado'],
                        $params['mercado']
                    ]);
                    $response['success'] = true;
                    break;
                case 'getCapturaOperacion':
                    $response['data'] = DB::select('SELECT * FROM sp_get_captura_operacion(?,?,?,?,?)', [
                        $params['fecha_pago'],
                        $params['oficina'],
                        $params['caja'],
                        $params['operacion'],
                        $params['mercado']
                    ]);
                    $response['success'] = true;
                    break;
                case 'insertPagosMercado':
                    $result = DB::select('SELECT * FROM sp_insert_pagos_mercado(?, ?, ?, ?, ?, ?, ?, ?, ?::json)', [
                        $params['fecha_pago'],
                        $params['oficina'],
                        $params['caja'],
                        $params['operacion'],
                        $params['usuario_id'],
                        $params['mercado'],
                        $params['categoria'],
                        $params['seccion'],
                        json_encode($params['pagos'])
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'deleteAdeudoLocal':
                    $result = DB::select('SELECT * FROM sp_delete_adeudo_local(?,?,?)', [
                        $params['id_local'],
                        $params['axo'],
                        $params['periodo']
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
