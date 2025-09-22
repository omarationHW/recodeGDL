<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones vía eRequest/eResponse
     */
    public function execute(Request $request)
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
                case 'RptEstadisticaAdeudos':
                    $eResponse = $this->rptEstadisticaAdeudos($params);
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }

    /**
     * Lógica para el reporte de estadística de adeudos
     * params: [axo, periodo, importe, opc]
     */
    private function rptEstadisticaAdeudos($params)
    {
        $axo = isset($params['axo']) ? (int)$params['axo'] : null;
        $periodo = isset($params['periodo']) ? (int)$params['periodo'] : null;
        $importe = isset($params['importe']) ? (float)$params['importe'] : 0;
        $opc = isset($params['opc']) ? (int)$params['opc'] : 1;

        if ($axo === null || $periodo === null || $opc === null) {
            return [
                'success' => false,
                'message' => 'Parámetros requeridos: axo, periodo, opc',
                'data' => null
            ];
        }

        // Llamada al stored procedure
        $query = "SELECT * FROM rpt_estadistica_adeudos(:p_axo, :p_periodo, :p_importe, :p_opc)";
        $result = DB::select($query, [
            'p_axo' => $axo,
            'p_periodo' => $periodo,
            'p_importe' => $importe,
            'p_opc' => $opc
        ]);

        return [
            'success' => true,
            'message' => 'Consulta exitosa',
            'data' => $result
        ];
    }
}
