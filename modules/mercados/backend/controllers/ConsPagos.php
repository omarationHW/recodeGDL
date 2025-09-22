<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsPagosController extends Controller
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
                case 'getPagosByLocal':
                    $response['data'] = $this->getPagosByLocal($params);
                    $response['success'] = true;
                    break;
                case 'addPago':
                    $response['data'] = $this->addPago($params);
                    $response['success'] = true;
                    break;
                case 'deletePago':
                    $response['data'] = $this->deletePago($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Consulta pagos por id_local
     */
    private function getPagosByLocal($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        $result = DB::select('CALL sp_cons_pagos_get_by_local(?)', [$id_local]);
        return $result;
    }

    /**
     * Agrega un pago
     */
    private function addPago($params)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer',
            'axo' => 'required|integer',
            'periodo' => 'required|integer',
            'fecha_pago' => 'required|date',
            'oficina_pago' => 'required|integer',
            'caja_pago' => 'required|string',
            'operacion_pago' => 'required|integer',
            'importe_pago' => 'required|numeric',
            'folio' => 'nullable|string',
            'id_usuario' => 'required|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('CALL sp_cons_pagos_add(?,?,?,?,?,?,?,?,?,?)', [
            $params['id_local'],
            $params['axo'],
            $params['periodo'],
            $params['fecha_pago'],
            $params['oficina_pago'],
            $params['caja_pago'],
            $params['operacion_pago'],
            $params['importe_pago'],
            $params['folio'] ?? null,
            $params['id_usuario']
        ]);
        return $result;
    }

    /**
     * Elimina un pago por id_pago_local
     */
    private function deletePago($params)
    {
        $id_pago_local = $params['id_pago_local'] ?? null;
        if (!$id_pago_local) {
            throw new \Exception('id_pago_local es requerido');
        }
        $result = DB::select('CALL sp_cons_pagos_delete(?)', [$id_pago_local]);
        return $result;
    }
}
