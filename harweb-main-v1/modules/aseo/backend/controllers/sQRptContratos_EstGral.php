<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar procedimientos almacenados
     * Entrada: {
     *   "eRequest": {
     *     "procedure": "nombre_del_sp",
     *     "parameters": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $procedure = $input['procedure'] ?? null;
        $parameters = $input['parameters'] ?? [];

        if (!$procedure) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Procedure name is required.'
                ]
            ], 400);
        }

        try {
            // Construir llamada dinámica al SP
            $paramPlaceholders = '';
            $paramValues = [];
            if (!empty($parameters)) {
                $paramPlaceholders = implode(', ', array_map(function($k) { return ':' . $k; }, array_keys($parameters)));
                $paramValues = $parameters;
            }
            $sql = "CALL $procedure($paramPlaceholders)";
            $result = DB::select($sql, $paramValues);

            return response()->json([
                'eResponse' => [
                    'success' => true,
                    'data' => $result
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $e->getMessage()
                ]
            ], 500);
        }
    }
}
