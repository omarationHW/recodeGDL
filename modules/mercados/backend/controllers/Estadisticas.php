<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EstadisticasController extends Controller
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
                case 'getEstadisticasGlobal':
                    $response['data'] = $this->getEstadisticasGlobal($params);
                    $response['success'] = true;
                    break;
                case 'getEstadisticasImporte':
                    $response['data'] = $this->getEstadisticasImporte($params);
                    $response['success'] = true;
                    break;
                case 'getDesgloceAdeudosPorImporte':
                    $response['data'] = $this->getDesgloceAdeudosPorImporte($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error($e);
        }
        return response()->json($response);
    }

    /**
     * Estadística Global de Adeudos
     */
    private function getEstadisticasGlobal($params)
    {
        $year = $params['year'] ?? date('Y');
        $month = $params['month'] ?? date('n');
        $result = DB::select('CALL sp_estadisticas_global(?, ?)', [$year, $month]);
        return $result;
    }

    /**
     * Estadística de Adeudos >= Importe
     */
    private function getEstadisticasImporte($params)
    {
        $year = $params['year'] ?? date('Y');
        $month = $params['month'] ?? date('n');
        $importe = $params['importe'] ?? 0;
        $result = DB::select('CALL sp_estadisticas_importe(?, ?, ?)', [$year, $month, $importe]);
        return $result;
    }

    /**
     * Desglose de Adeudos por Importe
     */
    private function getDesgloceAdeudosPorImporte($params)
    {
        $year = $params['year'] ?? date('Y');
        $month = $params['month'] ?? date('n');
        $importe = $params['importe'] ?? 0;
        $result = DB::select('CALL sp_desgloce_adeudos_por_importe(?, ?, ?)', [$year, $month, $importe]);
        return $result;
    }
}
