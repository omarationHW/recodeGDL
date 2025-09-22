<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BonificacionesController extends Controller
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
            case 'bonificaciones.create':
                return $this->createBonificacion($params, $userId);
            case 'bonificaciones.update':
                return $this->updateBonificacion($params, $userId);
            case 'bonificaciones.delete':
                return $this->deleteBonificacion($params, $userId);
            case 'bonificaciones.getByOficio':
                return $this->getByOficio($params);
            case 'bonificaciones.getByFolio':
                return $this->getByFolio($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Crear bonificación
     */
    private function createBonificacion($params, $userId)
    {
        $validator = Validator::make($params, [
            'oficio' => 'required|integer',
            'axo' => 'required|integer',
            'doble' => 'required|string|max:1',
            'control_rcm' => 'required|integer',
            'cementerio' => 'required|string|max:1',
            'clase' => 'required|integer',
            'clase_alfa' => 'required|string',
            'seccion' => 'required|integer',
            'seccion_alfa' => 'required|string',
            'linea' => 'required|integer',
            'linea_alfa' => 'required|string',
            'fosa' => 'required|integer',
            'fosa_alfa' => 'required|string',
            'fecha_ofic' => 'required|date',
            'importe_bonificar' => 'required|numeric',
            'importe_bonificado' => 'required|numeric',
            'importe_resto' => 'required|numeric',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        try {
            $result = DB::select('CALL sp_bonificaciones_create(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                $params['oficio'],
                $params['axo'],
                $params['doble'],
                $params['control_rcm'],
                $params['cementerio'],
                $params['clase'],
                $params['clase_alfa'],
                $params['seccion'],
                $params['seccion_alfa'],
                $params['linea'],
                $params['linea_alfa'],
                $params['fosa'],
                $params['fosa_alfa'],
                $params['fecha_ofic'],
                $params['importe_bonificar'],
                $params['importe_bonificado'],
                $params['importe_resto'],
                $userId,
                now(),
                null // output param for error
            ]);
            return response()->json([
                'success' => true,
                'message' => 'Registro dado de alta',
                'data' => $result
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    /**
     * Modificar bonificación
     */
    private function updateBonificacion($params, $userId)
    {
        $validator = Validator::make($params, [
            'oficio' => 'required|integer',
            'axo' => 'required|integer',
            'doble' => 'required|string|max:1',
            'fecha_ofic' => 'required|date',
            'importe_bonificar' => 'required|numeric',
            'importe_bonificado' => 'required|numeric',
            'importe_resto' => 'required|numeric',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        try {
            $result = DB::select('CALL sp_bonificaciones_update(?,?,?,?,?,?,?,?)', [
                $params['oficio'],
                $params['axo'],
                $params['doble'],
                $params['fecha_ofic'],
                $params['importe_bonificar'],
                $params['importe_bonificado'],
                $params['importe_resto'],
                $userId
            ]);
            return response()->json([
                'success' => true,
                'message' => 'Registro modificado',
                'data' => $result
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    /**
     * Borrar bonificación
     */
    private function deleteBonificacion($params, $userId)
    {
        $validator = Validator::make($params, [
            'oficio' => 'required|integer',
            'axo' => 'required|integer',
            'doble' => 'required|string|max:1',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        try {
            $result = DB::select('CALL sp_bonificaciones_delete(?,?,?,?)', [
                $params['oficio'],
                $params['axo'],
                $params['doble'],
                $userId
            ]);
            return response()->json([
                'success' => true,
                'message' => 'Registro borrado',
                'data' => $result
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null
            ], 500);
        }
    }

    /**
     * Obtener bonificación por oficio/axo/doble
     */
    private function getByOficio($params)
    {
        $validator = Validator::make($params, [
            'oficio' => 'required|integer',
            'axo' => 'required|integer',
            'doble' => 'required|string|max:1',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        $result = DB::select('SELECT * FROM ta_13_bonifrcm WHERE oficio = ? AND axo = ? AND doble = ?', [
            $params['oficio'],
            $params['axo'],
            $params['doble']
        ]);
        return response()->json([
            'success' => true,
            'message' => 'Consulta exitosa',
            'data' => $result
        ]);
    }

    /**
     * Obtener datos de fosa por folio
     */
    private function getByFolio($params)
    {
        $validator = Validator::make($params, [
            'folio' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ], 422);
        }
        $result = DB::select('SELECT a.*, b.nombre as cementerio_nombre FROM ta_13_datosrcm a JOIN tc_13_cementerios b ON a.cementerio = b.cementerio WHERE a.control_rcm = ?', [
            $params['folio']
        ]);
        return response()->json([
            'success' => true,
            'message' => 'Consulta exitosa',
            'data' => $result
        ]);
    }
}
