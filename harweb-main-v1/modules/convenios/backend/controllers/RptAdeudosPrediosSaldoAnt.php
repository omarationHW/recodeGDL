<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class RptAdeudosPrediosSaldoAntController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario RptAdeudosPrediosSaldoAnt
     * Entrada: {
     *   "eRequest": {
     *     "action": "getReport", // o "getSubtipos", "getSaldoAnterior", etc.
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
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [];
        try {
            switch ($action) {
                case 'getReport':
                    $response = $this->getReport($params);
                    break;
                case 'getSubtipos':
                    $response = $this->getSubtipos($params);
                    break;
                case 'getSaldoAnterior':
                    $response = $this->getSaldoAnterior($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada'
                    ]], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => $e->getMessage()
            ]], 500);
        }
    }

    /**
     * Obtiene el reporte principal de adeudos predios saldo anterior
     * params: subtipo, fechadsd, fechahst, est
     */
    private function getReport($params)
    {
        $validator = Validator::make($params, [
            'subtipo' => 'required|integer',
            'fechadsd' => 'required|date',
            'fechahst' => 'required|date',
            'est' => 'required|string|max:1'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('CALL sp_rpt_adeudos_predios_saldo_ant(?, ?, ?, ?)', [
            $params['subtipo'],
            $params['fechadsd'],
            $params['fechahst'],
            $params['est']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Obtiene los subtipos disponibles para el catálogo
     */
    private function getSubtipos($params)
    {
        $tipo = $params['tipo'] ?? 14;
        $result = DB::select('SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = ?', [$tipo]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Obtiene el saldo anterior de un predio
     * params: subtipo, id_conv_predio, fechadsd
     */
    private function getSaldoAnterior($params)
    {
        $validator = Validator::make($params, [
            'subtipo' => 'required|integer',
            'id_conv_predio' => 'required|integer',
            'fechadsd' => 'required|date'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $result = DB::select('CALL sp_get_saldo_anterior_predio(?, ?, ?)', [
            $params['subtipo'],
            $params['id_conv_predio'],
            $params['fechadsd']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }
}
