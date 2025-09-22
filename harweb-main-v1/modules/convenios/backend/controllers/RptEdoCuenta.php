<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class EdoCuentaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario EdoCuenta
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'getTipos':
                    $tipos = DB::select('SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo');
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $tipos,
                        'message' => ''
                    ];
                    break;
                case 'getSubTipos':
                    $tipo = $params['tipo'] ?? null;
                    $subtipos = DB::select('SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = ? ORDER BY subtipo', [$tipo]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $subtipos,
                        'message' => ''
                    ];
                    break;
                case 'getEdoCuenta':
                    $tipo = $params['tipo'] ?? null;
                    $subtipo = $params['subtipo'] ?? null;
                    $result = DB::select('CALL sp_get_edo_cuenta(?, ?)', [$tipo, $subtipo]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $result,
                        'message' => ''
                    ];
                    break;
                case 'getPagos':
                    $id_conv_resto = $params['id_conv_resto'] ?? null;
                    $pagos = DB::select('CALL sp_get_pagos_predio(?)', [$id_conv_resto]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $pagos,
                        'message' => ''
                    ];
                    break;
                case 'getAdeudos':
                    $id_conv_resto = $params['id_conv_resto'] ?? null;
                    $adeudos = DB::select('CALL sp_get_adeudos_predio(?)', [$id_conv_resto]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $adeudos,
                        'message' => ''
                    ];
                    break;
                case 'getRecargos':
                    $alov = $params['alov'] ?? null;
                    $mesv = $params['mesv'] ?? null;
                    $alo = $params['alo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $dia = $params['dia'] ?? null;
                    $diav = $params['diav'] ?? null;
                    $recargos = DB::select('SELECT sp_calcula_recargos(?, ?, ?, ?, ?, ?) AS porcentaje', [$alov, $mesv, $alo, $mes, $dia, $diav]);
                    $eResponse = [
                        'status' => 'ok',
                        'data' => $recargos,
                        'message' => ''
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse = [
                'status' => 'error',
                'data' => null,
                'message' => $ex->getMessage()
            ];
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
