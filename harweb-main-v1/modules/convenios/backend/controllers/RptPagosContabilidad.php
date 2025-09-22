<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RptPagosContabilidadController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'getRptPagosContabilidad':
                    $fecdesde = $eRequest['params']['fecdesde'];
                    $fechasta = $eRequest['params']['fechasta'];
                    $result = DB::select('SELECT * FROM sp_rpt_pagos_contabilidad(?, ?)', [$fecdesde, $fechasta]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getTipos':
                    $result = DB::select('SELECT * FROM sp_catalog_tipos()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
