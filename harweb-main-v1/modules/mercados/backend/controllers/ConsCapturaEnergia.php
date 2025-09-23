<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsCapturaEnergiaController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'success' => false,
                'data' => null,
                'message' => ''
            ]
        ];

        try {
            switch ($action) {
                case 'getPagosEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $result = DB::select('CALL sp_get_pagos_energia(?)', [$id_energia]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                case 'deletePagoEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $periodo = $params['periodo'] ?? null;
                    $usuario_id = $params['usuario_id'] ?? null;
                    $result = DB::select('CALL sp_delete_pago_energia(?,?,?,?)', [$id_energia, $axo, $periodo, $usuario_id]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                case 'restoreAdeudoEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $periodo = $params['periodo'] ?? null;
                    $cve_consumo = $params['cve_consumo'] ?? null;
                    $cantidad = $params['cantidad'] ?? null;
                    $importe = $params['importe'] ?? null;
                    $usuario_id = $params['usuario_id'] ?? null;
                    $result = DB::select('CALL sp_restore_adeudo_energia(?,?,?,?,?,?,?)', [
                        $id_energia, $axo, $periodo, $cve_consumo, $cantidad, $importe, $usuario_id
                    ]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['success'] = false;
            $response['eResponse']['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
