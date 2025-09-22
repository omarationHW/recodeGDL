<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class AdeudosCargaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar procesos (Adeudos_Carga)
     * Entrada: {
     *   "eRequest": {
     *     "action": "carga_adeudos",
     *     "ejercicio": 2024,
     *     "usuario_id": 23
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
        $ejercicio = $input['ejercicio'] ?? null;
        $usuario_id = $input['usuario_id'] ?? null;

        if ($action === 'carga_adeudos') {
            // Validación básica
            $validator = Validator::make($input, [
                'ejercicio' => 'required|integer|min:2000',
                'usuario_id' => 'required|integer|min:1',
            ]);
            if ($validator->fails()) {
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Datos inválidos',
                        'errors' => $validator->errors(),
                    ]
                ], 422);
            }

            try {
                // Llama al stored procedure de PostgreSQL
                $result = DB::select('CALL sp_carga_adeudos_contratos_vigentes(?, ?)', [
                    $ejercicio,
                    $usuario_id
                ]);
                return response()->json([
                    'eResponse' => [
                        'success' => true,
                        'message' => 'Carga de adeudos ejecutada correctamente',
                        'result' => $result
                    ]
                ]);
            } catch (\Exception $e) {
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Error al ejecutar la carga de adeudos',
                        'error' => $e->getMessage()
                    ]
                ], 500);
            }
        }

        return response()->json([
            'eResponse' => [
                'success' => false,
                'message' => 'Acción no soportada'
            ]
        ], 400);
    }
}
