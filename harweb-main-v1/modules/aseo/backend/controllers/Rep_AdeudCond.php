<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
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
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_tipo_aseo_catalog':
                    $result = DB::select('SELECT * FROM get_tipo_aseo_catalog()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_contrato_by_numero_tipoaseo':
                    $num_contrato = $params['num_contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    if (!$num_contrato || !$ctrol_aseo) {
                        throw new \Exception('Faltan parámetros requeridos');
                    }
                    $result = DB::select('SELECT * FROM get_contrato_by_numero_tipoaseo(?, ?)', [
                        $num_contrato, $ctrol_aseo
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_adeudos_condonados_by_contrato':
                    $control_contrato = $params['control_contrato'] ?? null;
                    if (!$control_contrato) {
                        throw new \Exception('Falta parámetro control_contrato');
                    }
                    $result = DB::select('SELECT * FROM get_adeudos_condonados_by_contrato(?)', [
                        $control_contrato
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_reporte_adeudos_condonados':
                    $control_contrato = $params['control_contrato'] ?? null;
                    $opcion = $params['opcion'] ?? 1;
                    if (!$control_contrato) {
                        throw new \Exception('Falta parámetro control_contrato');
                    }
                    $result = DB::select('SELECT * FROM get_reporte_adeudos_condonados(?, ?)', [
                        $control_contrato, $opcion
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
