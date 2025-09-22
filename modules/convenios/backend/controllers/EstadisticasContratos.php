<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class EstadisticasContratosController extends Controller
{
    /**
     * Endpoint unificado para todas las operaciones (eRequest/eResponse)
     * Ruta: POST /api/execute
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['eRequest']['action'] ?? null;
        $params = $input['eRequest']['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getEstadisticasContratos':
                    $response['data'] = $this->getEstadisticasContratos($params);
                    $response['success'] = true;
                    break;
                case 'getAdeudosVencidos':
                    $response['data'] = $this->getAdeudosVencidos($params);
                    $response['success'] = true;
                    break;
                case 'getRecaudacion':
                    $response['data'] = $this->getRecaudacion($params);
                    $response['success'] = true;
                    break;
                case 'getEstadisticasPeriodos':
                    $response['data'] = $this->getEstadisticasPeriodos($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error('EstadisticasContratosController error: ' . $e->getMessage());
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Obtiene estadísticas de contratos por año de obra y fondo
     * params: ['anio_obra' => int, 'fondo' => int]
     */
    private function getEstadisticasContratos($params)
    {
        $anioObra = $params['anio_obra'] ?? null;
        $fondo = $params['fondo'] ?? null;
        $result = DB::select('CALL spd_17_estadisticas_contratos(?, ?)', [$anioObra, $fondo]);
        return $result;
    }

    /**
     * Obtiene adeudos vencidos por año de obra y fondo
     * params: ['anio_obra' => int, 'fondo' => int]
     */
    private function getAdeudosVencidos($params)
    {
        $anioObra = $params['anio_obra'] ?? null;
        $fondo = $params['fondo'] ?? null;
        $result = DB::select('CALL spd_17_adeudo_venc(?, ?)', [$anioObra, $fondo]);
        return $result;
    }

    /**
     * Obtiene recaudación por fechas y clasificación
     * params: ['fecha_desde' => date, 'fecha_hasta' => date, 'clasificacion' => string]
     */
    private function getRecaudacion($params)
    {
        $fechaDesde = $params['fecha_desde'] ?? null;
        $fechaHasta = $params['fecha_hasta'] ?? null;
        $clasificacion = $params['clasificacion'] ?? null;
        $result = DB::select('CALL spd_17_recaudacion(?, ?, ?)', [$fechaDesde, $fechaHasta, $clasificacion]);
        return $result;
    }

    /**
     * Obtiene estadísticas por periodo
     * params: ['anio_obra' => int, 'adeudo_min' => float, 'detalle' => bool]
     */
    private function getEstadisticasPeriodos($params)
    {
        $anioObra = $params['anio_obra'] ?? null;
        $adeudoMin = $params['adeudo_min'] ?? 0;
        $detalle = $params['detalle'] ?? false;
        $result = DB::select('CALL spd_17_estadisticas_periodos(?, ?, ?)', [$anioObra, $adeudoMin, $detalle ? 1 : 0]);
        return $result;
    }
}
