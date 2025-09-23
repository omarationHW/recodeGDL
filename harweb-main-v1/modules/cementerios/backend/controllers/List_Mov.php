<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ListMovController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'list_movements':
                return $this->listMovements($params, $userId);
            case 'print_report':
                return $this->printReport($params, $userId);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ], 400);
        }
    }

    /**
     * Listar movimientos de cementerios
     */
    private function listMovements($params, $userId)
    {
        $validator = Validator::make($params, [
            'fecha1' => 'required|date',
            'fecha2' => 'required|date',
            'reca'   => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $result = DB::select('CALL sp_list_movements(?, ?, ?)', [
            $params['fecha1'],
            $params['fecha2'],
            $params['reca']
        ]);

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Generar reporte de movimientos (dummy, solo retorna datos)
     */
    private function printReport($params, $userId)
    {
        // En un sistema real, aquí se generaría el PDF o similar
        $validator = Validator::make($params, [
            'fecha1' => 'required|date',
            'fecha2' => 'required|date',
            'reca'   => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $result = DB::select('CALL sp_list_movements(?, ?, ?)', [
            $params['fecha1'],
            $params['fecha2'],
            $params['reca']
        ]);
        // Aquí se podría generar un PDF y devolver la URL o el binario
        return response()->json([
            'success' => true,
            'report_data' => $result,
            'message' => 'Reporte generado (simulado)'
        ]);
    }
}
