<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eParams = $request->input('eParams', []);

        switch ($eRequest) {
            case 'RptPrenomina':
                return $this->rptPrenomina($eParams);
            default:
                return response()->json([
                    'eResponse' => 'ERROR',
                    'eMessage' => 'eRequest no reconocido',
                    'eData' => null
                ], 400);
        }
    }

    /**
     * Ejecuta el reporte de prenomina
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function rptPrenomina($params)
    {
        // Validación de parámetros
        $fec1 = $params['fec1'] ?? null;
        $fec2 = $params['fec2'] ?? null;
        $recaud = $params['recaud'] ?? null;
        $recaud1 = $params['recaud1'] ?? null;

        if (!$fec1 || !$fec2 || !$recaud || !$recaud1) {
            return response()->json([
                'eResponse' => 'ERROR',
                'eMessage' => 'Parámetros insuficientes',
                'eData' => null
            ], 422);
        }

        // Llamada al stored procedure
        $result = DB::select('SELECT * FROM rpt_prenomina(:fec1, :fec2, :recaud, :recaud1)', [
            'fec1' => $fec1,
            'fec2' => $fec2,
            'recaud' => $recaud,
            'recaud1' => $recaud1
        ]);

        // Totales
        $totals = DB::select('SELECT * FROM rpt_prenomina_totals(:fec1, :fec2, :recaud, :recaud1)', [
            'fec1' => $fec1,
            'fec2' => $fec2,
            'recaud' => $recaud,
            'recaud1' => $recaud1
        ]);

        return response()->json([
            'eResponse' => 'OK',
            'eMessage' => 'Reporte generado',
            'eData' => [
                'rows' => $result,
                'totals' => $totals[0] ?? null
            ]
        ]);
    }
}
