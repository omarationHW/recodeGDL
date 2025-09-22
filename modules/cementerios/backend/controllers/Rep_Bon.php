<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RepBonController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Rep_Bon
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar|imprimir",
     *     "recaudadora": int,
     *     "pendientes": bool
     *   }
     * }
     * Salida: {
     *   "eResponse": {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? null;
        $recaudadora = $input['recaudadora'] ?? null;
        $pendientes = $input['pendientes'] ?? true;

        if (!in_array($action, ['listar', 'imprimir'])) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => 'Acción no soportada'
            ]]);
        }

        if (!$recaudadora || $recaudadora < 1 || $recaudadora > 9) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => 'Error en la Recaudadora'
            ]]);
        }

        // Llama al stored procedure para obtener los datos
        $result = DB::select('SELECT * FROM sp_rep_bon_listar(?, ?)', [
            $recaudadora,
            $pendientes ? 'pendientes' : 'todos'
        ]);

        if (empty($result)) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => 'No existen Registros'
            ]]);
        }

        // Si es imprimir, se puede devolver los datos para el reporte
        if ($action === 'imprimir') {
            // Aquí se podría generar un PDF o devolver los datos para que el frontend genere el reporte
            return response()->json(['eResponse' => [
                'success' => true,
                'data' => $result,
                'report' => true
            ]]);
        }

        // Listar
        return response()->json(['eResponse' => [
            'success' => true,
            'data' => $result
        ]]);
    }
}
