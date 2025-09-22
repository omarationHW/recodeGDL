<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'ConsPag400:searchByRecaudUrCuenta':
                    $recaud = (int)($params['recaud'] ?? 0);
                    $ur = (int)($params['ur'] ?? 0);
                    $cuenta = (int)($params['cuenta'] ?? 0);
                    $pagos = DB::select('SELECT * FROM sp_pagos_400_by_recaud_ur_cuenta(?, ?, ?)', [$recaud, $ur, $cuenta]);
                    $traspasos = DB::select('SELECT * FROM sp_trasp_400_by_recaud_ur_cuenta(?, ?, ?)', [$recaud, $ur, $cuenta]);
                    $observaciones = [];
                    if (count($traspasos) > 0) {
                        $traspaso = $traspasos[0];
                        $observaciones = DB::select('SELECT * FROM sp_obs_can_400_by_folio_anio(?, ?)', [
                            $traspaso->tfol ?? 0,
                            $traspaso->tafol ?? 0
                        ]);
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'pagos' => $pagos,
                        'traspasos' => $traspasos,
                        'observaciones' => $observaciones
                    ];
                    break;
                case 'ConsPag400:searchByAnioFolio':
                    $anio = (int)($params['anio'] ?? 0);
                    $folio = (int)($params['folio'] ?? 0);
                    $pagos = DB::select('SELECT * FROM sp_pagos_400_by_anio_folio(?, ?)', [$anio, $folio]);
                    $traspasos = DB::select('SELECT * FROM sp_trasp_400_by_anio_folio(?, ?)', [$anio, $folio]);
                    $observaciones = [];
                    if (count($traspasos) > 0) {
                        $traspaso = $traspasos[0];
                        $observaciones = DB::select('SELECT * FROM sp_obs_can_400_by_folio_anio(?, ?)', [
                            $traspaso->tfol ?? 0,
                            $traspaso->tafol ?? 0
                        ]);
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'pagos' => $pagos,
                        'traspasos' => $traspasos,
                        'observaciones' => $observaciones
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Invalid eRequest.';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
