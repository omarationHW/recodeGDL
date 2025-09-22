<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for ListAna report.
     * Endpoint: /api/execute
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getCajasByFechaRecaud':
                    $fecha = $params['fecha'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_cajas_by_fecha_recaud(?, ?)', [$fecha, $recaud]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getTotImp':
                    $fecha = $params['fecha'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_tot_imp(?, ?, ?)', [$fecha, $caja, $recaud]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'getMinFolio':
                    $fecha = $params['fecha'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_min_folio(?, ?, ?)', [$fecha, $caja, $recaud]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'getMaxFolio':
                    $fecha = $params['fecha'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_max_folio(?, ?, ?)', [$fecha, $caja, $recaud]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'getPagosDetalle':
                    $fecha = $params['fecha'] ?? null;
                    $caja = $params['caja'] ?? null;
                    $recaud = $params['recaud'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_pagos_detalle(?, ?, ?)', [$fecha, $caja, $recaud]);
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
