<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PagosEneConsController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'getPagosEnergia':
                return $this->getPagosEnergia($params);
            case 'addPagoEnergia':
                return $this->addPagoEnergia($params, $userId);
            case 'deletePagoEnergia':
                return $this->deletePagoEnergia($params, $userId);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ], 400);
        }
    }

    /**
     * Consulta pagos de energía eléctrica por id_energia
     */
    private function getPagosEnergia($params)
    {
        $idEnergia = $params['id_energia'] ?? null;
        if (!$idEnergia) {
            return response()->json([
                'success' => false,
                'message' => 'Parámetro id_energia requerido.'
            ], 422);
        }
        $result = DB::select('CALL sp_get_pagos_energia(?)', [$idEnergia]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Agrega un pago de energía eléctrica
     */
    private function addPagoEnergia($params, $userId)
    {
        $validator = Validator::make($params, [
            'id_energia' => 'required|integer',
            'axo' => 'required|integer',
            'periodo' => 'required|integer',
            'fecha_pago' => 'required|date',
            'oficina_pago' => 'required|integer',
            'caja_pago' => 'required|string|max:1',
            'operacion_pago' => 'required|integer',
            'importe_pago' => 'required|numeric',
            'cve_consumo' => 'required|string|max:1',
            'cantidad' => 'required|numeric',
            'folio' => 'nullable|string|max:18'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_add_pago_energia(?,?,?,?,?,?,?,?,?,?,?)', [
            $params['id_energia'],
            $params['axo'],
            $params['periodo'],
            $params['fecha_pago'],
            $params['oficina_pago'],
            $params['caja_pago'],
            $params['operacion_pago'],
            $params['importe_pago'],
            $params['cve_consumo'],
            $params['cantidad'],
            $params['folio'] ?? null,
            $userId
        ]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Elimina un pago de energía eléctrica
     */
    private function deletePagoEnergia($params, $userId)
    {
        $validator = Validator::make($params, [
            'id_pago_energia' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_delete_pago_energia(?,?)', [
            $params['id_pago_energia'],
            $userId
        ]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }
}
