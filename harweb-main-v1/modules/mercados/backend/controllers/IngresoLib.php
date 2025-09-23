<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class IngresoLibController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'get_mercados':
                    $response['data'] = DB::select('SELECT * FROM sp_get_mercados()');
                    $response['success'] = true;
                    break;
                case 'get_ingresos':
                    $validator = Validator::make($params, [
                        'mes' => 'required|integer|min:1|max:12',
                        'anio' => 'required|integer',
                        'mercado_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_ingresos_libertad(?, ?, ?)', [
                        $params['mes'],
                        $params['anio'],
                        $params['mercado_id']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get_cajas':
                    $validator = Validator::make($params, [
                        'mes' => 'required|integer|min:1|max:12',
                        'anio' => 'required|integer',
                        'mercado_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_cajas_libertad(?, ?, ?)', [
                        $params['mes'],
                        $params['anio'],
                        $params['mercado_id']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get_totals':
                    $validator = Validator::make($params, [
                        'mes' => 'required|integer|min:1|max:12',
                        'anio' => 'required|integer',
                        'mercado_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_get_totals_libertad(?, ?, ?)', [
                        $params['mes'],
                        $params['anio'],
                        $params['mercado_id']
                    ]);
                    $response['data'] = $result[0] ?? null;
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
