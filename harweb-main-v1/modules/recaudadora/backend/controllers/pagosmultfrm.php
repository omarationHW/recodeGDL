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
                case 'pagosmultfrm.searchPagosMultas':
                    $result = DB::select('SELECT * FROM pagosmultfrm_search_pagos_multas(?, ?, ?, ?, ?, ?)', [
                        $params['fecha'] ?? null,
                        $params['recaud'] ?? null,
                        $params['caja'] ?? null,
                        $params['folio'] ?? null,
                        $params['nombre'] ?? null,
                        $params['num_acta'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'pagosmultfrm.getMultaDetalle':
                    $result = DB::select('SELECT * FROM pagosmultfrm_get_multa_detalle(?)', [
                        $params['id_multa'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'pagosmultfrm.getPagosCan':
                    $result = DB::select('SELECT * FROM pagosmultfrm_get_pagoscan(?)', [
                        $params['cvepago'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'pagosmultfrm.getDescuentos':
                    $result = DB::select('SELECT * FROM pagosmultfrm_get_descuentos(?)', [
                        $params['id_multa'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'pagosmultfrm.getLey':
                    $result = DB::select('SELECT * FROM pagosmultfrm_get_ley(?, ?)', [
                        $params['id_dependencia'] ?? null,
                        $params['id_ley'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'pagosmultfrm.getInfraccion':
                    $result = DB::select('SELECT * FROM pagosmultfrm_get_infraccion(?, ?)', [
                        $params['id_dependencia'] ?? null,
                        $params['id_infraccion'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'pagosmultfrm.getDependencia':
                    $result = DB::select('SELECT * FROM pagosmultfrm_get_dependencia(?)', [
                        $params['id_dependencia'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
