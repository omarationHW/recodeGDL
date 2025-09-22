<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class RepACobrarController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Rep_a_Cobrar
     * Entrada: {
     *   "eRequest": {
     *     "action": "getReport|getRecaudadora|...",
     *     "params": { ... }
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
        $params = $input['params'] ?? [];
        $response = [];
        try {
            switch ($action) {
                case 'getReport':
                    $mes = $params['mes'] ?? null;
                    $id_rec = $params['id_rec'] ?? null;
                    if (!$mes || !$id_rec) {
                        return response()->json(['eResponse' => ['error' => 'Parámetros requeridos: mes, id_rec']], 400);
                    }
                    // Llama el SP de reporte
                    $result = DB::select('SELECT * FROM sp_rep_a_cobrar(?, ?)', [$mes, $id_rec]);
                    $response['report'] = $result;
                    break;
                case 'getRecaudadora':
                    $id_rec = $params['id_rec'] ?? null;
                    if (!$id_rec) {
                        return response()->json(['eResponse' => ['error' => 'Parámetro requerido: id_rec']], 400);
                    }
                    $result = DB::select('SELECT * FROM sp_get_recaudadora(?)', [$id_rec]);
                    $response['recaudadora'] = $result;
                    break;
                case 'getMeses':
                    $response['meses'] = [
                        ['value' => 1, 'label' => 'Enero'],
                        ['value' => 2, 'label' => 'Febrero'],
                        ['value' => 3, 'label' => 'Marzo'],
                        ['value' => 4, 'label' => 'Abril'],
                        ['value' => 5, 'label' => 'Mayo'],
                        ['value' => 6, 'label' => 'Junio'],
                        ['value' => 7, 'label' => 'Julio'],
                        ['value' => 8, 'label' => 'Agosto'],
                        ['value' => 9, 'label' => 'Septiembre'],
                        ['value' => 10, 'label' => 'Octubre'],
                        ['value' => 11, 'label' => 'Noviembre'],
                        ['value' => 12, 'label' => 'Diciembre']
                    ];
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }
}
