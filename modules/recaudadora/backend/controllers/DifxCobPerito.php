<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DifxCobPeritoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'getPeritos':
                return $this->getPeritos($params);
            case 'getDiferenciasByPerito':
                return $this->getDiferenciasByPerito($params);
            case 'printReport':
                return $this->printReport($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada'
                ], 400);
        }
    }

    /**
     * Consulta de peritos con diferencias en el periodo
     */
    public function getPeritos($params)
    {
        $fecha1 = $params['fecha1'] ?? null;
        $fecha2 = $params['fecha2'] ?? null;
        $vigencia = $params['vigencia'] ?? 'V';

        $peritos = DB::select('CALL sp_difxcobperito_peritos(?, ?, ?)', [$fecha1, $fecha2, $vigencia]);
        return response()->json([
            'success' => true,
            'data' => $peritos
        ]);
    }

    /**
     * Consulta de diferencias por perito
     */
    public function getDiferenciasByPerito($params)
    {
        $noperito = $params['noperito'] ?? null;
        $fecha1 = $params['fecha1'] ?? null;
        $fecha2 = $params['fecha2'] ?? null;
        $vigencia = $params['vigencia'] ?? 'V';

        $diferencias = DB::select('CALL sp_difxcobperito_diferencias(?, ?, ?, ?)', [$noperito, $fecha1, $fecha2, $vigencia]);
        return response()->json([
            'success' => true,
            'data' => $diferencias
        ]);
    }

    /**
     * Genera reporte PDF (dummy, solo endpoint)
     */
    public function printReport($params)
    {
        // Aquí se llamaría a un servicio de generación de PDF
        // Por ahora solo retorna success
        return response()->json([
            'success' => true,
            'message' => 'Reporte generado (dummy)'
        ]);
    }
}
