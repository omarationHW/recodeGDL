<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        try {
            switch ($action) {
                case 'buscar_concesion':
                    $result = DB::select('SELECT * FROM buscar_concesion(:control)', [
                        'control' => $params['control'] ?? null
                    ]);
                    return response()->json(['success' => true, 'data' => $result]);

                case 'actualizar_concesion':
                    $result = DB::select('SELECT * FROM actualizar_concesion(:opc, :id_34_datos, :concesionario, :ubicacion, :licencia, :superficie, :descrip, :aso_ini, :mes_ini)', [
                        'opc' => $params['opc'],
                        'id_34_datos' => $params['id_34_datos'],
                        'concesionario' => $params['concesionario'],
                        'ubicacion' => $params['ubicacion'],
                        'licencia' => $params['licencia'],
                        'superficie' => $params['superficie'],
                        'descrip' => $params['descrip'],
                        'aso_ini' => $params['aso_ini'],
                        'mes_ini' => $params['mes_ini']
                    ]);
                    return response()->json(['success' => true, 'data' => $result]);

                case 'verificar_pagos':
                    $result = DB::select('SELECT * FROM verificar_pagos(:id_datos, :periodo)', [
                        'id_datos' => $params['id_datos'],
                        'periodo' => $params['periodo']
                    ]);
                    return response()->json(['success' => true, 'data' => $result]);

                // ... otros casos según los SP definidos

                default:
                    return response()->json(['success' => false, 'error' => 'Acción no soportada'], 400);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
                'trace' => config('app.debug') ? $e->getTraceAsString() : null
            ], 500);
        }
    }
}
