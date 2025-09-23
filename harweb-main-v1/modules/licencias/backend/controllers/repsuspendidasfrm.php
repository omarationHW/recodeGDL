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
            case 'repsuspendidas_report':
                return $this->repsuspendidasReport($params);
            default:
                return response()->json([
                    'eResponse' => 'error',
                    'message' => 'Unknown eRequest',
                ], 400);
        }
    }

    /**
     * Generate the suspended licenses report
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function repsuspendidasReport($params)
    {
        // Validate input
        $year = isset($params['year']) ? intval($params['year']) : 0;
        $date_from = isset($params['date_from']) ? $params['date_from'] : null;
        $date_to = isset($params['date_to']) ? $params['date_to'] : null;
        $tipo_suspension = isset($params['tipo_suspension']) ? intval($params['tipo_suspension']) : 0; // 0=Todas, 1=Bloqueo, etc.

        if ($year === 0 && (empty($date_from) || empty($date_from)) && empty($date_to)) {
            return response()->json([
                'eResponse' => 'error',
                'message' => 'Debes indicar el año o las fechas de las licencias ...',
            ], 422);
        }

        // Call stored procedure
        try {
            $results = DB::select('SELECT * FROM report_licencias_suspendidas(?, ?, ?, ?)', [
                $year,
                $date_from,
                $date_to,
                $tipo_suspension
            ]);

            if (empty($results)) {
                return response()->json([
                    'eResponse' => 'ok',
                    'data' => [],
                    'message' => 'No se encontraron licencias con esas condiciones ...',
                ]);
            }

            return response()->json([
                'eResponse' => 'ok',
                'data' => $results,
                'total' => count($results)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => 'error',
                'message' => 'Error al obtener el reporte: ' . $e->getMessage(),
            ], 500);
        }
    }
}
