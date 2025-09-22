<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RptEmisionRbosAbastosController extends Controller
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
                case 'getReportData':
                    $response['data'] = $this->getReportData($params);
                    $response['success'] = true;
                    break;
                case 'getRequerimientos':
                    $response['data'] = $this->getRequerimientos($params);
                    $response['success'] = true;
                    break;
                case 'getRecargosMes':
                    $response['data'] = $this->getRecargosMes($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Obtiene los datos principales del reporte de emisión de recibos de abastos
     */
    private function getReportData($params)
    {
        $oficina = $params['oficina'] ?? null;
        $mercado = $params['mercado'] ?? null;
        $axo = $params['axo'] ?? null;
        $periodo = $params['periodo'] ?? null;
        if (!$oficina || !$mercado || !$axo || !$periodo) {
            throw new \Exception('Parámetros insuficientes');
        }
        $result = DB::select('CALL sp_rpt_emision_rbos_abastos(?, ?, ?, ?)', [
            $oficina, $mercado, $axo, $periodo
        ]);
        return $result;
    }

    /**
     * Obtiene los requerimientos asociados a un local
     */
    private function getRequerimientos($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('Parámetro id_local requerido');
        }
        $result = DB::select('CALL sp_get_requerimientos_abastos(?)', [$id_local]);
        return $result;
    }

    /**
     * Obtiene los recargos del mes para un año y periodo
     */
    private function getRecargosMes($params)
    {
        $axo = $params['axo'] ?? null;
        $mes = $params['mes'] ?? null;
        if (!$axo || !$mes) {
            throw new \Exception('Parámetros axo y mes requeridos');
        }
        $result = DB::select('CALL sp_get_recargos_mes_abastos(?, ?)', [$axo, $mes]);
        return $result;
    }
}
