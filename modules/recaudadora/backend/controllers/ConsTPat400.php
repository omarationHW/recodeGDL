<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'consultarPagosTPat400':
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $operacion = $params['operacion'] ?? null;

                    $result = DB::select('SELECT * FROM sp_consultar_pagos_tpat400(?, ?, ?, ?)', [
                        $fecha,
                        $recaud,
                        $caja,
                        $operacion
                    ]);

                    if (empty($result)) {
                        $eResponse['message'] = 'No se localizaron pagos de transmisiones patrimoniales en el AS400';
                    } else {
                        $eResponse['success'] = true;
                        $eResponse['data'] = $result;
                    }
                    break;

                case 'consultarDetalleTPat400':
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $operacion = $params['operacion'] ?? null;
                    $lugar = $params['lugar'] ?? null;

                    $result = DB::select('SELECT * FROM sp_consultar_detalle_tpat400(?, ?, ?, ?, ?)', [
                        $fecha,
                        $recaud,
                        $caja,
                        $operacion,
                        $lugar
                    ]);

                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
