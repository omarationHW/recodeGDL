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
    public function handle(Request $request)
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
                case 'get_tabla_info':
                    $par_tab = $params['par_tab'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_tabla_info(?)', [$par_tab]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_etiq':
                    $par_tab = $params['par_tab'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_etiq(?)', [$par_tab]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_recaudadoras':
                    $result = DB::select('SELECT * FROM sp_get_recaudadoras()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_operaciones':
                    $result = DB::select('SELECT * FROM sp_get_operaciones()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_pagados':
                    $p_Control = $params['p_Control'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_pagados(?)', [$p_Control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_datos_concesion':
                    $par_tab = $params['par_tab'] ?? null;
                    $par_control = $params['par_control'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_datos_concesion(?, ?)', [$par_tab, $par_control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
