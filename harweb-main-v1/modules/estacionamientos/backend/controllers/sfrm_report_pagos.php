<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                case 'report_folios_pagados':
                    // params: reca (int), fechora (date)
                    $result = DB::select('SELECT * FROM report_folios_pagados(:reca, :fechora)', [
                        'reca' => $params['reca'],
                        'fechora' => $params['fechora']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'report_folios_elaborados_usuario':
                    // params: fechora (date), vigila (int)
                    $result = DB::select('SELECT * FROM report_folios_elaborados_usuario(:fechora, :vigila)', [
                        'fechora' => $params['fechora'],
                        'vigila' => $params['vigila']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'report_folios_adeudo_por_inspector':
                    // params: fechora (date)
                    $result = DB::select('SELECT * FROM report_folios_adeudo_por_inspector(:fechora)', [
                        'fechora' => $params['fechora']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_usuarios':
                    $result = DB::select('SELECT * FROM ta_12_passwords');
                    $response['success'] = true;
                    $response['data'] = $result;
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
