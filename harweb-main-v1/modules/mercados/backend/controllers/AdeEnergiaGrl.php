<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeEnergiaGrlController extends Controller
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
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'getMercadosByRecaudadora':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $response['data'] = DB::select('SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = ? AND cuenta_energia > 0 ORDER BY num_mercado_nvo', [$params['id_rec']]);
                    $response['success'] = true;
                    break;
                case 'getAdeudosEnergiaGrl':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer',
                        'axo' => 'required|integer',
                        'mes' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_ade_energia_grl(?, ?, ?, ?)', [
                        $params['id_rec'],
                        $params['num_mercado_nvo'],
                        $params['axo'],
                        $params['mes']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    // Implementar lógica de exportación si es necesario
                    $response['message'] = 'Funcionalidad de exportación no implementada en este endpoint.';
                    break;
                case 'printReport':
                    // Implementar lógica de impresión si es necesario
                    $response['message'] = 'Funcionalidad de impresión no implementada en este endpoint.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
