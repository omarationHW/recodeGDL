<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class GAdeudosOpcMultController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT id_rec, id_zona, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'getCajas':
                    $response['data'] = DB::select('SELECT id_rec, caja FROM ta_12_operaciones ORDER BY id_rec, caja');
                    $response['success'] = true;
                    break;
                case 'getEtiquetas':
                    $par_tab = $params['par_tab'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM t34_etiq WHERE cve_tab = ?', [$par_tab]);
                    $response['success'] = true;
                    break;
                case 'getTablas':
                    $par_tab = $params['par_tab'] ?? null;
                    $response['data'] = DB::select('SELECT a.cve_tab, a.nombre, b.descripcion FROM t34_tablas a, t34_unidades b WHERE a.cve_tab = ? AND b.cve_tab = a.cve_tab GROUP BY a.cve_tab, a.nombre, b.descripcion ORDER BY a.cve_tab, a.nombre, b.descripcion', [$par_tab]);
                    $response['success'] = true;
                    break;
                case 'buscarConcesion':
                    $par_tab = $params['par_tab'] ?? null;
                    $par_control = $params['par_control'] ?? null;
                    $result = DB::select('SELECT * FROM cob34_gdatosg_02(?, ?)', [$par_tab, $par_control]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'buscarAdeudos':
                    $par_tabla = $params['par_tabla'] ?? null;
                    $par_id_datos = $params['par_id_datos'] ?? null;
                    $par_aso = $params['par_aso'] ?? null;
                    $par_mes = $params['par_mes'] ?? null;
                    $result = DB::select('SELECT * FROM cob34_gdetade_01(?, ?, ?, ?)', [$par_tabla, $par_id_datos, $par_aso, $par_mes]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'buscarPagados':
                    $p_Control = $params['p_Control'] ?? null;
                    $result = DB::select('SELECT * FROM t34_pagos WHERE id_datos = ? AND id_stat = (SELECT id_34_stat FROM t34_status WHERE cve_stat = \'P\') ORDER BY periodo', [$p_Control]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'ejecutarOpcion':
                    // Validar parámetros
                    $validator = Validator::make($params, [
                        'par_id_34_datos' => 'required|integer',
                        'par_Axo' => 'required|integer',
                        'par_Mes' => 'required|integer',
                        'par_Fecha' => 'required|date',
                        'par_Id_Rec' => 'required|integer',
                        'par_Caja' => 'required|string',
                        'par_Consec' => 'required|integer',
                        'par_Folio_rcbo' => 'required|string',
                        'par_tab' => 'required|string',
                        'par_status' => 'required|string',
                        'par_Opc' => 'required|string',
                        'par_usuario' => 'required|string',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM upd34_gen_adeudos_ind(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['par_id_34_datos'],
                        $params['par_Axo'],
                        $params['par_Mes'],
                        $params['par_Fecha'],
                        $params['par_Id_Rec'],
                        $params['par_Caja'],
                        $params['par_Consec'],
                        $params['par_Folio_rcbo'],
                        $params['par_tab'],
                        $params['par_status'],
                        $params['par_Opc'],
                        $params['par_usuario'],
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('GAdeudosOpcMultController error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
