<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EdoCuentaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del EdoCuenta
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|report|recargos|sumPagos",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? null;
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'list':
                    $tipo = $input['tipo'] ?? null;
                    $subtipo = $input['subtipo'] ?? null;
                    $result = DB::select('SELECT * FROM edo_cuenta_list(:tipo, :subtipo)', [
                        'tipo' => $tipo,
                        'subtipo' => $subtipo
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'report':
                    $tipo = $input['tipo'] ?? null;
                    $subtipo = $input['subtipo'] ?? null;
                    $result = DB::select('SELECT * FROM edo_cuenta_report(:tipo, :subtipo)', [
                        'tipo' => $tipo,
                        'subtipo' => $subtipo
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos':
                    $id_conv_resto = $input['id_conv_resto'] ?? null;
                    $pago_parcial = $input['pago_parcial'] ?? null;
                    $result = DB::select('SELECT * FROM edo_cuenta_calc_recargos(:id_conv_resto, :pago_parcial)', [
                        'id_conv_resto' => $id_conv_resto,
                        'pago_parcial' => $pago_parcial
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'sumPagos':
                    $id_conv_resto = $input['id_conv_resto'] ?? null;
                    $result = DB::select('SELECT * FROM edo_cuenta_sum_pagos(:id_conv_resto)', [
                        'id_conv_resto' => $id_conv_resto
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(["eResponse" => $response]);
    }
}
