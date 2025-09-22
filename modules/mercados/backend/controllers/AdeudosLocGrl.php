<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosLocGrlController extends Controller
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
                    $id_rec = $params['id_rec'] ?? null;
                    $response['data'] = DB::select('SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = ? AND tipo_emision <> ? ORDER BY num_mercado_nvo', [$id_rec, 'B']);
                    $response['success'] = true;
                    break;
                case 'getAdeudosLocalesGrl':
                    $id_rec = $params['id_rec'] ?? null;
                    $num_mercado = $params['num_mercado'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('CALL sp_adeudos_loc_grl(?, ?, ?, ?)', [$id_rec, $num_mercado, $axo, $mes]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    // Implementar lógica de exportación a Excel si es necesario
                    $response['success'] = true;
                    $response['message'] = 'Exportación a Excel no implementada en API.';
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
