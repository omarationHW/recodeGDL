<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ParcialidadesVencidasPrediosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);

        switch ($action) {
            case 'getParcialidadesVencidasPredios':
                return $this->getParcialidadesVencidasPredios($params);
            default:
                return response()->json([
                    'status' => 'error',
                    'message' => 'Acción no soportada'
                ], 400);
        }
    }

    /**
     * Consulta de Parcialidades Vencidas de Predios
     * params: {
     *   subtipo: int,
     *   fechahst: string (YYYY-MM-DD),
     *   est: string ('A'|'B'|'P')
     * }
     */
    public function getParcialidadesVencidasPredios($params)
    {
        $subtipo = $params['subtipo'] ?? null;
        $fechahst = $params['fechahst'] ?? null;
        $est = $params['est'] ?? 'A';

        if (!$subtipo || !$fechahst) {
            return response()->json([
                'status' => 'error',
                'message' => 'Parámetros requeridos: subtipo, fechahst'
            ], 422);
        }

        // Llama al stored procedure de PostgreSQL
        $result = DB::select('SELECT * FROM sp_parcialidades_vencidas_predios(?, ?, ?)', [
            $subtipo, $fechahst, $est
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $result
        ]);
    }
}
