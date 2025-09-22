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
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'gconsulta2.getEtiquetas':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_get_etiquetas(?)', [
                        $params['par_tab']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'gconsulta2.getTablas':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_get_tablas(?)', [
                        $params['par_tab']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'gconsulta2.buscarCoincide':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_busca_coincide(?, ?, ?)', [
                        $params['par_tab'],
                        $params['tipo_busqueda'],
                        $params['dato_busqueda']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'gconsulta2.buscarCont':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_busca_cont(?, ?)', [
                        $params['par_tab'],
                        $params['par_control']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'gconsulta2.buscarAdeudos':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_busca_adeudos(?, ?, ?, ?)', [
                        $params['par_tabla'],
                        $params['par_id_datos'],
                        $params['par_aso'],
                        $params['par_mes']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'gconsulta2.buscarTotales':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_busca_totales(?, ?, ?, ?)', [
                        $params['par_tabla'],
                        $params['par_id_datos'],
                        $params['par_aso'],
                        $params['par_mes']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'gconsulta2.buscarPagados':
                    $data = DB::select('SELECT * FROM sp_gconsulta2_busca_pagados(?)', [
                        $params['p_Control']
                    ]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
