<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute endpoint.
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
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'get_unidades_recolec':
                    // params: ejercicio (int), order_by (string: ctrol|cve|descripcion|costo)
                    $ejercicio = $params['ejercicio'] ?? null;
                    $order_by = $params['order_by'] ?? 'ctrol';
                    $order_map = [
                        'ctrol' => 'ctrol_recolec',
                        'cve' => 'cve_recolec',
                        'descripcion' => 'descripcion',
                        'costo' => 'costo_unidad'
                    ];
                    $order_field = $order_map[$order_by] ?? 'ctrol_recolec';
                    $result = DB::select('SELECT * FROM sp_get_unidades_recolec(?, ?)', [$ejercicio, $order_field]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_ejercicios':
                    // For dropdowns, get distinct ejercicios
                    $result = DB::select('SELECT DISTINCT ejercicio_recolec FROM ta_16_unidades ORDER BY ejercicio_recolec DESC');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
