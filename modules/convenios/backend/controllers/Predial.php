<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PredialController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del módulo Predial
     * Entrada: eRequest (JSON)
     * Salida: eResponse (JSON)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $user = $request->user();
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'buscarCuenta':
                    $validator = Validator::make($params, [
                        'recaud' => 'required|integer',
                        'urbrus' => 'required|string|max:1',
                        'cuenta' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_predial_buscar_cuenta(?, ?, ?)', [
                        $params['recaud'], $params['urbrus'], $params['cuenta']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'calcularLiquidacion':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'asal' => 'required|integer',
                        'bsal' => 'required|integer',
                        'asalf' => 'required|integer',
                        'bsalf' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_predial_calcular_liquidacion(?, ?, ?, ?, ?)', [
                        $params['cvecuenta'], $params['asal'], $params['bsal'], $params['asalf'], $params['bsalf']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'confirmarPago':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'usuario_id' => 'required|integer',
                        'forma_pago' => 'required|string',
                        'importe' => 'required|numeric',
                        'detalle' => 'required|array',
                        'aportacion_voluntaria' => 'nullable|numeric',
                        'diferencia' => 'nullable|numeric',
                        'cheque' => 'nullable|array',
                        'tarjeta' => 'nullable|array',
                        'pago_minimo' => 'nullable|boolean',
                        'pago_especial' => 'nullable|boolean'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_predial_confirmar_pago(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['cvecuenta'],
                        $params['usuario_id'],
                        $params['forma_pago'],
                        $params['importe'],
                        json_encode($params['detalle']),
                        $params['aportacion_voluntaria'] ?? 0,
                        $params['diferencia'] ?? 0,
                        json_encode($params['cheque'] ?? []),
                        json_encode($params['tarjeta'] ?? []),
                        $params['pago_minimo'] ?? false,
                        $params['pago_especial'] ?? false
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'imprimirRecibo':
                    $validator = Validator::make($params, [
                        'cvepago' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_predial_imprimir_recibo(?)', [
                        $params['cvepago']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                case 'mostrarDescuentos':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'asal' => 'required|integer',
                        'bsal' => 'required|integer',
                        'asalf' => 'required|integer',
                        'bsalf' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_predial_mostrar_descuentos(?, ?, ?, ?, ?)', [
                        $params['cvecuenta'], $params['asal'], $params['bsal'], $params['asalf'], $params['bsalf']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                default:
                    $eResponse['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
