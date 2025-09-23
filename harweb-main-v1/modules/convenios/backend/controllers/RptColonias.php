<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);

        switch ($eRequest) {
            case 'RptColoniasList':
                return $this->rptColoniasList($params);
            // Aquí se pueden agregar más casos para otros formularios o procesos
            default:
                return response()->json([
                    'eResponse' => 'ERROR',
                    'message' => 'eRequest not supported',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Ejecuta el reporte de colonias llamando el stored procedure correspondiente
     *
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function rptColoniasList($params)
    {
        try {
            // Llama al stored procedure y obtiene los resultados
            $results = DB::select('SELECT * FROM rpt_colonias_list()');
            // Cuenta total de colonias
            $total = count($results);
            return response()->json([
                'eResponse' => 'OK',
                'message' => 'Colonias obtenidas correctamente',
                'data' => [
                    'colonias' => $results,
                    'total' => $total
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => 'ERROR',
                'message' => $e->getMessage(),
                'data' => null
            ], 500);
        }
    }
}
