<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaPagDiversosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o Sanctum

        switch ($action) {
            case 'buscarPagosDiversos':
                return $this->buscarPagosDiversos($params, $user);
            case 'grabarPagosDiversos':
                return $this->grabarPagosDiversos($params, $user);
            case 'getRecaudadoras':
                return $this->getRecaudadoras();
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Buscar pagos diversos pendientes de carga
     */
    private function buscarPagosDiversos($params, $user)
    {
        $validator = Validator::make($params, [
            'fecha_desde' => 'required|date',
            'fecha_hasta' => 'required|date',
            'recaudadora' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }
        // Seguridad: solo usuarios con nivel 1 pueden buscar de otras recaudadoras
        if ($user->nivel != 1 && $user->id_rec != $params['recaudadora']) {
            return response()->json([
                'success' => false,
                'message' => 'No tienes autorización para cargar pagos de otra recaudadora.'
            ], 403);
        }
        $result = DB::select('SELECT * FROM sp_buscar_pagos_diversos(?, ?, ?)', [
            $params['fecha_desde'],
            $params['fecha_hasta'],
            $params['recaudadora']
        ]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Grabar pagos diversos seleccionados
     */
    private function grabarPagosDiversos($params, $user)
    {
        $validator = Validator::make($params, [
            'pagos' => 'required|array|min:1',
            'pagos.*.fecing' => 'required|date',
            'pagos.*.recing' => 'required|integer',
            'pagos.*.cajing' => 'required|string',
            'pagos.*.opcaja' => 'required|integer',
            'pagos.*.colonia' => 'required|integer',
            'pagos.*.obra' => 'required|integer',
            'pagos.*.numero' => 'required|integer',
            'pagos.*.tipo_rbo' => 'required|string',
            'pagos.*.mes_desde' => 'required|integer',
            'pagos.*.axo_desde' => 'required|integer',
            'pagos.*.pagado' => 'required|numeric'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }
        $errores = [];
        DB::beginTransaction();
        try {
            foreach ($params['pagos'] as $pago) {
                $res = DB::select('SELECT * FROM sp_grabar_pago_diverso(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $pago['fecing'],
                    $pago['recing'],
                    $pago['cajing'],
                    $pago['opcaja'],
                    $pago['colonia'],
                    $pago['obra'],
                    $pago['numero'],
                    $pago['tipo_rbo'],
                    $pago['mes_desde'],
                    $pago['axo_desde'],
                    $pago['pagado'],
                    $user->id_usuario,
                    $user->nivel
                ]);
                if (isset($res[0]->error) && $res[0]->error) {
                    $errores[] = [
                        'pago' => $pago,
                        'error' => $res[0]->error
                    ];
                }
            }
            if (count($errores) > 0) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Errores al grabar algunos pagos',
                    'errors' => $errores
                ], 500);
            }
            DB::commit();
            return response()->json([
                'success' => true,
                'message' => 'Carga de Pagos de Diversos ejecutada satisfactoriamente.'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error inesperado: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener lista de recaudadoras
     */
    private function getRecaudadoras()
    {
        $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }
}
