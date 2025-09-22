<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosEstController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'get_periodos':
                    $response['data'] = DB::select('SELECT aso_mes_recargo FROM ta_16_recargos ORDER BY aso_mes_recargo');
                    $response['success'] = true;
                    break;
                case 'get_estadistico_pagos':
                    $validator = Validator::make($params, [
                        'aso_in' => 'required|integer',
                        'mes_in' => 'required|integer',
                        'aso_fin' => 'required|integer',
                        'mes_fin' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $periodo_inicio = sprintf('%04d-%02d', $params['aso_in'], $params['mes_in']);
                    $periodo_fin = sprintf('%04d-%02d', $params['aso_fin'], $params['mes_fin']);
                    $result = DB::select('SELECT * FROM sp_estadistico_pagos(?, ?)', [$periodo_inicio, $periodo_fin]);
                    $response['data'] = $result;
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
