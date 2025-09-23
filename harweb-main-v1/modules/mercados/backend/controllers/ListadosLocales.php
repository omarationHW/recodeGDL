<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ListadosLocalesController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'getRecaudadoras':
                return response()->json($this->getRecaudadoras());
            case 'getMercadosByRecaudadora':
                return response()->json($this->getMercadosByRecaudadora($params['recaudadora_id']));
            case 'getPadronLocales':
                return response()->json($this->getPadronLocales($params));
            case 'getMovimientosLocales':
                return response()->json($this->getMovimientosLocales($params));
            case 'getPagosLocales':
                return response()->json($this->getPagosLocales($params));
            case 'getIngresoZonificado':
                return response()->json($this->getIngresoZonificado($params));
            case 'exportPadronExcel':
                return $this->exportPadronExcel($params);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    private function getRecaudadoras()
    {
        $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return ['recaudadoras' => $result];
    }

    private function getMercadosByRecaudadora($recaudadora_id)
    {
        $result = DB::select('SELECT num_mercado_nvo, descripcion, categoria FROM ta_11_mercados WHERE oficina = ? ORDER BY num_mercado_nvo', [$recaudadora_id]);
        return ['mercados' => $result];
    }

    private function getPadronLocales($params)
    {
        $recaudadora_id = $params['recaudadora_id'];
        $mercado_id = $params['mercado_id'];
        $result = DB::select('CALL sp_get_padron_locales(?, ?)', [$recaudadora_id, $mercado_id]);
        return ['locales' => $result];
    }

    private function getMovimientosLocales($params)
    {
        $fecha_desde = $params['fecha_desde'];
        $fecha_hasta = $params['fecha_hasta'];
        $recaudadora_id = $params['recaudadora_id'];
        $result = DB::select('CALL sp_get_movimientos_locales(?, ?, ?)', [$fecha_desde, $fecha_hasta, $recaudadora_id]);
        return ['movimientos' => $result];
    }

    private function getPagosLocales($params)
    {
        $fecha_desde = $params['fecha_desde'];
        $fecha_hasta = $params['fecha_hasta'];
        $recaudadora_id = $params['recaudadora_id'];
        $result = DB::select('CALL sp_get_pagos_locales(?, ?, ?)', [$fecha_desde, $fecha_hasta, $recaudadora_id]);
        return ['pagos' => $result];
    }

    private function getIngresoZonificado($params)
    {
        $fecha_desde = $params['fecha_desde'];
        $fecha_hasta = $params['fecha_hasta'];
        $result = DB::select('CALL sp_get_ingreso_zonificado(?, ?)', [$fecha_desde, $fecha_hasta]);
        return ['ingresos' => $result];
    }

    private function exportPadronExcel($params)
    {
        // Aquí se implementaría la lógica de exportación a Excel
        // Puede usar Laravel Excel o similar
        // Por simplicidad, retornamos un mensaje
        return response()->json(['message' => 'Exportación a Excel iniciada (implementación pendiente)']);
    }
}
