<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosLocalesController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
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
                case 'getAdeudosLocales':
                    $axo = $params['axo'] ?? date('Y');
                    $oficina = $params['oficina'] ?? null;
                    $periodo = $params['periodo'] ?? null;
                    $result = DB::select('CALL sp_get_adeudos_locales(?, ?, ?)', [$axo, $oficina, $periodo]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getMesesAdeudo':
                    $id_local = $params['id_local'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $result = DB::select('CALL sp_get_meses_adeudo(?, ?)', [$id_local, $axo]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getRenta':
                    $axo = $params['axo'] ?? null;
                    $categoria = $params['categoria'] ?? null;
                    $seccion = $params['seccion'] ?? null;
                    $clave_cuota = $params['clave_cuota'] ?? null;
                    $result = DB::select('CALL sp_get_renta(?, ?, ?, ?)', [$axo, $categoria, $seccion, $clave_cuota]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    // Implementar lógica de exportación a Excel (puede ser un job o respuesta de archivo)
                    $response['success'] = true;
                    $response['message'] = 'Exportación iniciada.';
                    break;
                case 'printReport':
                    // Implementar lógica de generación de reporte PDF (puede ser un job o respuesta de archivo)
                    $response['success'] = true;
                    $response['message'] = 'Reporte generado.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
