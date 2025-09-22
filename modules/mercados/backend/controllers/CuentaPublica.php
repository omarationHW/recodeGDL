<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CuentaPublicaController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response['success'] = true;
                    break;
                case 'getEstadAdeudo':
                    $oficina = $params['oficina'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $periodo = $params['periodo'] ?? null;
                    $response['data'] = DB::select('CALL sp_cuenta_publica_estad_adeudo(?, ?, ?)', [$oficina, $axo, $periodo]);
                    $response['success'] = true;
                    break;
                case 'getTotalAdeudo':
                    $oficina = $params['oficina'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $periodo = $params['periodo'] ?? null;
                    $response['data'] = DB::select('CALL sp_cuenta_publica_total_adeudo(?, ?, ?)', [$oficina, $axo, $periodo]);
                    $response['success'] = true;
                    break;
                case 'getCuentaPublicaReport':
                    $oficina = $params['oficina'] ?? null;
                    $axo = $params['axo'] ?? null;
                    $response['data'] = DB::select('CALL sp_cuenta_publica_reporte(?, ?)', [$axo, $oficina]);
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
