<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsCapturaFechaController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'getPagosByFecha':
                    $response['data'] = $this->getPagosByFecha($params);
                    $response['success'] = true;
                    break;
                case 'deletePagos':
                    $response['data'] = $this->deletePagos($params);
                    $response['success'] = true;
                    break;
                case 'getOficinas':
                    $response['data'] = $this->getOficinas();
                    $response['success'] = true;
                    break;
                case 'getCajasByOficina':
                    $response['data'] = $this->getCajasByOficina($params);
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
     * Obtener pagos por fecha/oficina/caja/operacion
     */
    private function getPagosByFecha($params)
    {
        $fecha = $params['fecha'] ?? null;
        $oficina = $params['oficina'] ?? null;
        $caja = $params['caja'] ?? null;
        $operacion = $params['operacion'] ?? null;

        $result = DB::select('CALL sp_get_pagos_by_fecha(?, ?, ?, ?)', [
            $fecha, $oficina, $caja, $operacion
        ]);
        return $result;
    }

    /**
     * Borrar pagos seleccionados (array de pagos)
     */
    private function deletePagos($params)
    {
        $pagos = $params['pagos'] ?? [];
        $usuario = $params['usuario'] ?? null;
        $result = [];
        foreach ($pagos as $pago) {
            $res = DB::select('CALL sp_delete_pago_local(?, ?, ?, ?)', [
                $pago['id_local'],
                $pago['axo'],
                $pago['periodo'],
                $usuario
            ]);
            $result[] = $res;
        }
        return $result;
    }

    /**
     * Obtener lista de oficinas
     */
    private function getOficinas()
    {
        $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return $result;
    }

    /**
     * Obtener cajas por oficina
     */
    private function getCajasByOficina($params)
    {
        $oficina = $params['oficina'] ?? null;
        $result = DB::select('SELECT caja FROM ta_12_cajas WHERE id_rec = ?', [$oficina]);
        return $result;
    }
}
