<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ContratosEstController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'get_tipo_aseo':
                    $response['data'] = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $response['success'] = true;
                    break;
                case 'get_dia_limite':
                    $mes = $params['mes'] ?? date('n');
                    $response['data'] = DB::select('SELECT * FROM ta_16_dia_limite WHERE mes = ?', [$mes]);
                    $response['success'] = true;
                    break;
                case 'get_contratos_estadistica':
                    $cve_aseo = $params['cve_aseo'] ?? 'T';
                    $result = DB::select('SELECT * FROM sp_contratos_estadistica(?)', [$cve_aseo]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get_contratos_estadistica_totales':
                    $result = DB::select('SELECT * FROM sp_contratos_estadistica_totales()');
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get_periodos':
                    $response['data'] = DB::select('SELECT DISTINCT EXTRACT(YEAR FROM aso_mes_recargo) as year, EXTRACT(MONTH FROM aso_mes_recargo) as month FROM ta_16_recargos ORDER BY year DESC, month DESC');
                    $response['success'] = true;
                    break;
                case 'get_estadistica_periodo':
                    $aso_in = $params['aso_in'] ?? null;
                    $mes_in = $params['mes_in'] ?? null;
                    $aso_fin = $params['aso_fin'] ?? null;
                    $mes_fin = $params['mes_fin'] ?? null;
                    $result = DB::select('SELECT * FROM sp_contratos_estadistica_periodo(?,?,?,?)', [$aso_in, $mes_in, $aso_fin, $mes_fin]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error('ContratosEstController error: ' . $e->getMessage());
        }

        return response()->json($response);
    }
}
