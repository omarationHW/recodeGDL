<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaPagEnergiaController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'buscarAdeudosEnergia':
                return $this->buscarAdeudosEnergia($payload);
            case 'cargarPagosEnergia':
                return $this->cargarPagosEnergia($payload, $userId);
            case 'consultarPagosEnergia':
                return $this->consultarPagosEnergia($payload);
            case 'listarRecaudadoras':
                return $this->listarRecaudadoras();
            case 'listarSecciones':
                return $this->listarSecciones();
            case 'listarCajas':
                return $this->listarCajas($payload);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    /**
     * Buscar adeudos de energía eléctrica para un local
     */
    private function buscarAdeudosEnergia($payload)
    {
        $validator = Validator::make($payload, [
            'oficina' => 'required|integer',
            'mercado' => 'required|integer',
            'categoria' => 'required|integer',
            'seccion' => 'required|string',
            'local' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('CALL sp_buscar_adeudos_energia(?,?,?,?,?)', [
            $payload['oficina'],
            $payload['mercado'],
            $payload['categoria'],
            $payload['seccion'],
            $payload['local']
        ]);
        return response()->json(['data' => $result]);
    }

    /**
     * Cargar pagos de energía eléctrica
     */
    private function cargarPagosEnergia($payload, $userId)
    {
        $validator = Validator::make($payload, [
            'pagos' => 'required|array|min:1',
            'fecha_pago' => 'required|date',
            'oficina_pago' => 'required|integer',
            'caja_pago' => 'required|string',
            'operacion_pago' => 'required|integer',
            'folio' => 'required|string',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        DB::beginTransaction();
        try {
            foreach ($payload['pagos'] as $pago) {
                DB::statement('CALL sp_cargar_pago_energia(?,?,?,?,?,?,?,?,?,?,?,?)', [
                    $pago['id_energia'],
                    $pago['axo'],
                    $pago['periodo'],
                    $payload['fecha_pago'],
                    $payload['oficina_pago'],
                    $payload['caja_pago'],
                    $payload['operacion_pago'],
                    $pago['importe'],
                    $pago['cve_consumo'],
                    $pago['cantidad'],
                    $payload['folio'],
                    $userId
                ]);
            }
            DB::commit();
            return response()->json(['success' => true, 'message' => 'Pagos cargados correctamente']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Consultar pagos de energía eléctrica
     */
    private function consultarPagosEnergia($payload)
    {
        $validator = Validator::make($payload, [
            'id_energia' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('CALL sp_consultar_pagos_energia(?)', [
            $payload['id_energia']
        ]);
        return response()->json(['data' => $result]);
    }

    /**
     * Listar recaudadoras
     */
    private function listarRecaudadoras()
    {
        $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return response()->json(['data' => $result]);
    }

    /**
     * Listar secciones
     */
    private function listarSecciones()
    {
        $result = DB::select('SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion');
        return response()->json(['data' => $result]);
    }

    /**
     * Listar cajas para una recaudadora
     */
    private function listarCajas($payload)
    {
        $validator = Validator::make($payload, [
            'oficina' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('SELECT caja FROM ta_12_operaciones WHERE id_rec = ? ORDER BY caja', [
            $payload['oficina']
        ]);
        return response()->json(['data' => $result]);
    }
}
