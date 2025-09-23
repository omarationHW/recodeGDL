<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'eRequest' => 'required|array',
            'eRequest.action' => 'required|string',
            'eRequest.data' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Parámetros inválidos',
                    'errors' => $validator->errors(),
                ]
            ], 422);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);

        switch ($action) {
            case 'RptPadronEnergia.getReport':
                return $this->getPadronEnergiaReport($data);
            default:
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada',
                    ]
                ], 400);
        }
    }

    /**
     * Obtiene el reporte de padrón de energía eléctrica del mercado
     * @param array $data
     * @return \Illuminate\Http\JsonResponse
     */
    private function getPadronEnergiaReport($data)
    {
        $validator = Validator::make($data, [
            'oficina' => 'required|integer',
            'mercado' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Parámetros de entrada inválidos',
                    'errors' => $validator->errors(),
                ]
            ], 422);
        }

        $oficina = $data['oficina'];
        $mercado = $data['mercado'];

        try {
            $result = DB::select('SELECT * FROM rpt_padron_energia($1, $2)', [$oficina, $mercado]);
            $total_registros = count($result);
            $total_cuota = array_sum(array_map(function($row) { return (float)$row->cantidad; }, $result));
            $descripcion_mercado = $total_registros > 0 ? $result[0]->descripcion : '';

            return response()->json([
                'eResponse' => [
                    'success' => true,
                    'message' => 'Reporte generado correctamente',
                    'data' => [
                        'descripcion_mercado' => $descripcion_mercado,
                        'registros' => $result,
                        'total_registros' => $total_registros,
                        'total_cuota' => $total_cuota
                    ]
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Error al obtener el reporte',
                    'error' => $e->getMessage(),
                ]
            ], 500);
        }
    }
}
