<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del sistema (eRequest/eResponse)
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'getDiaLimite':
                    $mes = $params['mes'] ?? null;
                    $result = DB::select('CALL sp_get_dia_limite(?)', [$mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getEmpresa':
                    $num_empresa = $params['num_empresa'] ?? null;
                    $ctrol_emp = $params['ctrol_emp'] ?? null;
                    $result = DB::select('CALL sp_get_empresa(?, ?)', [$num_empresa, $ctrol_emp]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getAdeudosVencidos':
                    $control_contrato = $params['control_contrato'] ?? null;
                    $dia_limite = $params['dia_limite'] ?? null;
                    $aso_hoy = $params['aso_hoy'] ?? null;
                    $mes_hoy = $params['mes_hoy'] ?? null;
                    $periodo = $params['periodo'] ?? null;
                    $result = DB::select('CALL sp_get_adeudos_vencidos(?, ?, ?, ?, ?)', [
                        $control_contrato, $dia_limite, $aso_hoy, $mes_hoy, $periodo
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getImporteRecargo':
                    $importe = $params['importe'] ?? null;
                    $ctrol_operacion = $params['ctrol_operacion'] ?? null;
                    $aso_mes_pago = $params['aso_mes_pago'] ?? null;
                    $aso_hoy = $params['aso_hoy'] ?? null;
                    $mes_hoy = $params['mes_hoy'] ?? null;
                    $result = DB::select('CALL sp_get_importe_recargo(?, ?, ?, ?, ?)', [
                        $importe, $ctrol_operacion, $aso_mes_pago, $aso_hoy, $mes_hoy
                    ]);
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
