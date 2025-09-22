<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosEnergiaController extends Controller
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
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'getAdeudosEnergia':
                    $axo = $params['axo'] ?? null;
                    $oficina = $params['oficina'] ?? null;
                    $response['data'] = DB::select('CALL sp_get_adeudos_energia(?, ?)', [$axo, $oficina]);
                    $response['success'] = true;
                    break;
                case 'getMesesAdeudoEnergia':
                    $id_energia = $params['id_energia'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $response['data'] = DB::select('CALL sp_get_meses_adeudo_energia(?, ?)', [$id_energia, $axo]);
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    // Implementación de exportación a Excel (puede usar Laravel Excel)
                    // Aquí solo se retorna la data, el frontend debe manejar el archivo
                    $axo = $params['axo'] ?? null;
                    $oficina = $params['oficina'] ?? null;
                    $data = DB::select('CALL sp_get_adeudos_energia(?, ?)', [$axo, $oficina]);
                    $response['data'] = $data;
                    $response['success'] = true;
                    break;
                case 'printReport':
                    // Implementación de generación de reporte PDF (puede usar dompdf)
                    // Aquí solo se retorna la data, el frontend debe manejar el archivo
                    $axo = $params['axo'] ?? null;
                    $oficina = $params['oficina'] ?? null;
                    $data = DB::select('CALL sp_get_adeudos_energia(?, ?)', [$axo, $oficina]);
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
