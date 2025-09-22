<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class EstadisticosLicController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario repEstadisticosLicfrm
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [];
        try {
            switch ($action) {
                case 'reporte_licencias_rango':
                    $response = $this->reporteLicenciasRango($params);
                    break;
                case 'reporte_licencias_giro_zona':
                    $response = $this->reporteLicenciasGiroZona($params);
                    break;
                case 'reporte_giros_reglamentados_zona':
                    $response = $this->reporteGirosReglamentadosZona($params);
                    break;
                case 'reporte_licencias_reglamentadas_rango':
                    $response = $this->reporteLicenciasReglamentadasRango($params);
                    break;
                case 'reporte_pagos_licencias_rango':
                    $response = $this->reportePagosLicenciasRango($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'error' => 'Acción no soportada'
                    ]], 400);
            }
            return response()->json(['eResponse' => [
                'success' => true,
                'data' => $response
            ]]);
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            return response()->json(['eResponse' => [
                'success' => false,
                'error' => $e->getMessage()
            ]], 500);
        }
    }

    private function reporteLicenciasRango($params)
    {
        $fecha1 = $params['fecha1'] ?? null;
        $fecha2 = $params['fecha2'] ?? null;
        $validator = Validator::make($params, [
            'fecha1' => 'required|date',
            'fecha2' => 'required|date',
        ]);
        if ($validator->fails()) {
            throw new \Exception('Fechas requeridas');
        }
        $result = DB::select('CALL sp_rep_estadisticos_lic_rango(?, ?)', [$fecha1, $fecha2]);
        return $result;
    }

    private function reporteLicenciasGiroZona($params)
    {
        $result = DB::select('CALL sp_rep_estadisticos_lic_giro_zona()');
        return $result;
    }

    private function reporteGirosReglamentadosZona($params)
    {
        $clasificacion = $params['clasificacion'] ?? null; // null, 'C', 'D'
        $result = DB::select('CALL sp_rep_estadisticos_giros_reglamentados_zona(?)', [$clasificacion]);
        return $result;
    }

    private function reporteLicenciasReglamentadasRango($params)
    {
        $fecha1 = $params['fecha1'] ?? null;
        $fecha2 = $params['fecha2'] ?? null;
        $clasificacion = $params['clasificacion'] ?? null;
        $validator = Validator::make($params, [
            'fecha1' => 'required|date',
            'fecha2' => 'required|date',
        ]);
        if ($validator->fails()) {
            throw new \Exception('Fechas requeridas');
        }
        $result = DB::select('CALL sp_rep_estadisticos_lic_reglamentadas_rango(?, ?, ?)', [$fecha1, $fecha2, $clasificacion]);
        return $result;
    }

    private function reportePagosLicenciasRango($params)
    {
        $fecha1 = $params['fecha1'] ?? null;
        $fecha2 = $params['fecha2'] ?? null;
        $validator = Validator::make($params, [
            'fecha1' => 'required|date',
            'fecha2' => 'required|date',
        ]);
        if ($validator->fails()) {
            throw new \Exception('Fechas requeridas');
        }
        $result = DB::select('CALL sp_rep_estadisticos_pagos_lic_rango(?, ?)', [$fecha1, $fecha2]);
        return $result;
    }
}
