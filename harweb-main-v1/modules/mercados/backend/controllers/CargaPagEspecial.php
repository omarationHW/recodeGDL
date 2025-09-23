<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaPagEspecialController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getMercados':
                    $response['data'] = DB::select('SELECT * FROM sp_get_mercados()');
                    $response['success'] = true;
                    break;
                case 'getAdeudosLocal':
                    $validator = Validator::make($payload, [
                        'oficina' => 'required|integer',
                        'mercado' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'local' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_adeudos_local(?,?,?,?,?)', [
                        $payload['oficina'],
                        $payload['mercado'],
                        $payload['categoria'],
                        $payload['seccion'],
                        $payload['local']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'cargarPagosEspecial':
                    $validator = Validator::make($payload, [
                        'pagos' => 'required|array',
                        'fecha_pago' => 'required|date',
                        'oficina_pago' => 'required|integer',
                        'caja_pago' => 'required|string',
                        'operacion_pago' => 'required|integer',
                        'usuario_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cargar_pagos_especial(?,?,?,?,?,?)', [
                        json_encode($payload['pagos']),
                        $payload['fecha_pago'],
                        $payload['oficina_pago'],
                        $payload['caja_pago'],
                        $payload['operacion_pago'],
                        $payload['usuario_id']
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
