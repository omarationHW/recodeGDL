<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronGlobalController extends Controller
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
            case 'getPadronGlobal':
                return $this->getPadronGlobal($params);
            case 'exportPadronGlobalExcel':
                return $this->exportPadronGlobalExcel($params);
            case 'getPadronGlobalReport':
                return $this->getPadronGlobalReport($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ], 400);
        }
    }

    /**
     * Consulta el padrón global de locales
     */
    public function getPadronGlobal($params)
    {
        $validator = Validator::make($params, [
            'year' => 'required|integer',
            'month' => 'required|integer',
            'status' => 'required|string',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $year = $params['year'];
        $month = $params['month'];
        $status = $params['status'];

        $result = DB::select('CALL sp_padron_global(?, ?, ?)', [$year, $month, $status]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Exporta el padrón global a Excel
     */
    public function exportPadronGlobalExcel($params)
    {
        // Similar a getPadronGlobal pero retorna archivo Excel
        // Aquí solo se retorna JSON de ejemplo
        return response()->json([
            'success' => true,
            'message' => 'Exportación a Excel generada (simulada)'
        ]);
    }

    /**
     * Genera el reporte PDF del padrón global
     */
    public function getPadronGlobalReport($params)
    {
        // Similar a getPadronGlobal pero retorna PDF
        // Aquí solo se retorna JSON de ejemplo
        return response()->json([
            'success' => true,
            'message' => 'Reporte PDF generado (simulado)'
        ]);
    }
}
