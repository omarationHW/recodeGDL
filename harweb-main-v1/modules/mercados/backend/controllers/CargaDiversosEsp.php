<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaDiversosEspController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (API Unificada)
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data');
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getAdeudos':
                    $fechaPago = $data['fecha_pago'];
                    $result = DB::select('CALL sp_get_adeudos_diversos_esp(?)', [$fechaPago]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getLocales':
                    $params = [
                        $data['oficina'],
                        $data['num_mercado'],
                        $data['categoria'],
                        $data['seccion'],
                        $data['local'],
                        $data['letra_local'],
                        $data['bloque']
                    ];
                    $result = DB::select('CALL sp_get_locales_diversos_esp(?,?,?,?,?,?,?)', $params);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'cargarPagos':
                    $pagos = $data['pagos'];
                    $usuario = $data['usuario'];
                    $fecha_pago = $data['fecha_pago'];
                    $result = DB::select('CALL sp_cargar_pagos_diversos_esp(?, ?, ?)', [json_encode($pagos), $usuario, $fecha_pago]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getFechasDescuento':
                    $mes = $data['mes'];
                    $result = DB::select('CALL sp_get_fecha_descuento(?)', [$mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
