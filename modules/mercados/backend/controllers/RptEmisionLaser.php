<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class RptEmisionLaserController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario RptEmisionLaser
     * Entrada: {
     *   "eRequest": {
     *     "action": "getReport|getLocales|getPagos|getMesAdeudo|getRequerimientos|getRecargos|getFecDes|getSubT",
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
        $action = $input['action'] ?? '';
        $params = $input['params'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'getReport':
                    $result = $this->getReport($params);
                    break;
                case 'getLocales':
                    $result = $this->getLocales($params);
                    break;
                case 'getPagos':
                    $result = $this->getPagos($params);
                    break;
                case 'getMesAdeudo':
                    $result = $this->getMesAdeudo($params);
                    break;
                case 'getRequerimientos':
                    $result = $this->getRequerimientos($params);
                    break;
                case 'getRecargos':
                    $result = $this->getRecargos($params);
                    break;
                case 'getFecDes':
                    $result = $this->getFecDes($params);
                    break;
                case 'getSubT':
                    $result = $this->getSubT($params);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error($ex);
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => $error ? ['error' => $error] : $result
        ]);
    }

    private function getReport($params)
    {
        // Llama al SP principal de reporte
        $oficina = $params['oficina'] ?? null;
        $axo = $params['axo'] ?? null;
        $periodo = $params['periodo'] ?? null;
        $mercado = $params['mercado'] ?? null;
        $data = DB::select('CALL sp_rpt_emision_laser(?, ?, ?, ?)', [$oficina, $axo, $periodo, $mercado]);
        return ['report' => $data];
    }

    private function getLocales($params)
    {
        $oficina = $params['oficina'] ?? null;
        $mercado = $params['mercado'] ?? null;
        $axo = $params['axo'] ?? null;
        $periodo = $params['periodo'] ?? null;
        $data = DB::select('CALL sp_get_locales_emision_laser(?, ?, ?, ?)', [$oficina, $mercado, $axo, $periodo]);
        return ['locales' => $data];
    }

    private function getPagos($params)
    {
        $id_local = $params['id_local'] ?? null;
        $axo = $params['axo'] ?? null;
        $periodo = $params['periodo'] ?? null;
        $data = DB::select('CALL sp_get_pagos_local(?, ?, ?)', [$id_local, $axo, $periodo]);
        return ['pagos' => $data];
    }

    private function getMesAdeudo($params)
    {
        $id_local = $params['id_local'] ?? null;
        $axo = $params['axo'] ?? null;
        $data = DB::select('CALL sp_get_mes_adeudo(?, ?)', [$id_local, $axo]);
        return ['mes_adeudo' => $data];
    }

    private function getRequerimientos($params)
    {
        $modulo = $params['modulo'] ?? 11;
        $id_local = $params['id_local'] ?? null;
        $data = DB::select('CALL sp_get_requerimientos(?, ?)', [$modulo, $id_local]);
        return ['requerimientos' => $data];
    }

    private function getRecargos($params)
    {
        $axo = $params['axo'] ?? null;
        $mes = $params['mes'] ?? null;
        $data = DB::select('CALL sp_get_recargos_mes(?, ?)', [$axo, $mes]);
        return ['recargos' => $data];
    }

    private function getFecDes($params)
    {
        $mes = $params['mes'] ?? null;
        $data = DB::select('CALL sp_get_fecha_descuento(?)', [$mes]);
        return ['fec_des' => $data];
    }

    private function getSubT($params)
    {
        $id_local = $params['id_local'] ?? null;
        $axo = $params['axo'] ?? null;
        $periodo = $params['periodo'] ?? null;
        $data = DB::select('CALL sp_get_subtotal_local(?, ?, ?)', [$id_local, $axo, $periodo]);
        return ['subtotal' => $data];
    }
}
