<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class IndividualPrediosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getPredioById':
                    $response['data'] = $this->getPredioById($params);
                    $response['success'] = true;
                    break;
                case 'getAdeudosByPredio':
                    $response['data'] = $this->getAdeudosByPredio($params);
                    $response['success'] = true;
                    break;
                case 'getTotPagadoByPredio':
                    $response['data'] = $this->getTotPagadoByPredio($params);
                    $response['success'] = true;
                    break;
                case 'getRecargosByAdeudo':
                    $response['data'] = $this->getRecargosByAdeudo($params);
                    $response['success'] = true;
                    break;
                case 'getDiaVencimiento':
                    $response['data'] = $this->getDiaVencimiento($params);
                    $response['success'] = true;
                    break;
                case 'getDiasInhabiles':
                    $response['data'] = $this->getDiasInhabiles($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Obtiene los datos del predio por ID
     */
    private function getPredioById($params)
    {
        $id_conv_predio = $params['id_conv_predio'] ?? null;
        if (!$id_conv_predio) {
            throw new \Exception('Falta id_conv_predio');
        }
        $result = DB::select('SELECT * FROM sp_get_predio_by_id(?)', [$id_conv_predio]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene los adeudos del predio
     */
    private function getAdeudosByPredio($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        $fecha = $params['fecha'] ?? null;
        if (!$id_conv_resto || !$fecha) {
            throw new \Exception('Faltan parámetros');
        }
        $result = DB::select('SELECT * FROM sp_get_adeudos_by_predio(?, ?)', [$id_conv_resto, $fecha]);
        return $result;
    }

    /**
     * Obtiene el total pagado por predio
     */
    private function getTotPagadoByPredio($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Falta id_conv_resto');
        }
        $result = DB::select('SELECT * FROM sp_get_tot_pagado_by_predio(?)', [$id_conv_resto]);
        return $result;
    }

    /**
     * Obtiene el recargo calculado para un adeudo
     */
    private function getRecargosByAdeudo($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        $importe = $params['importe'] ?? null;
        $fecha_venc = $params['fecha_venc'] ?? null;
        $fecha_actual = $params['fecha_actual'] ?? null;
        if (!$id_conv_resto || !$importe || !$fecha_venc || !$fecha_actual) {
            throw new \Exception('Faltan parámetros');
        }
        $result = DB::select('SELECT * FROM sp_calc_recargos_adeudo(?, ?, ?, ?)', [
            $id_conv_resto, $importe, $fecha_venc, $fecha_actual
        ]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene el día de vencimiento para el predio
     */
    private function getDiaVencimiento($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        $anio = $params['anio'] ?? null;
        $mes = $params['mes'] ?? null;
        if (!$id_conv_resto || !$anio || !$mes) {
            throw new \Exception('Faltan parámetros');
        }
        $result = DB::select('SELECT * FROM sp_get_dia_vencimiento(?, ?, ?)', [
            $id_conv_resto, $anio, $mes
        ]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene los días inhábiles para una fecha
     */
    private function getDiasInhabiles($params)
    {
        $fecha = $params['fecha'] ?? null;
        if (!$fecha) {
            throw new \Exception('Falta fecha');
        }
        $result = DB::select('SELECT * FROM sp_get_dias_inhabiles(?)', [$fecha]);
        return $result;
    }
}
