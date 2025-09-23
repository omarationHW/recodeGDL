<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Unidades de Recolección
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|delete",
     *     "entity": "unidades_recoleccion",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $entity = $eRequest['entity'] ?? null;
        $params = $eRequest['params'] ?? [];

        if ($entity === 'unidades_recoleccion') {
            switch ($action) {
                case 'list':
                    $ejercicio = $params['ejercicio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_unidades_recoleccion_list(?)', [$ejercicio]);
                    return response()->json(['eResponse' => $result]);
                case 'create':
                    $result = DB::select('SELECT * FROM sp_unidades_recoleccion_create(?,?,?,?,?,?)', [
                        $params['ejercicio_recolec'],
                        $params['cve_recolec'],
                        $params['descripcion'],
                        $params['costo_unidad'],
                        $params['costo_exed'],
                        $params['usuario_id'] ?? null
                    ]);
                    return response()->json(['eResponse' => $result]);
                case 'update':
                    $result = DB::select('SELECT * FROM sp_unidades_recoleccion_update(?,?,?,?,?,?,?)', [
                        $params['ctrol_recolec'],
                        $params['ejercicio_recolec'],
                        $params['cve_recolec'],
                        $params['descripcion'],
                        $params['costo_unidad'],
                        $params['costo_exed'],
                        $params['usuario_id'] ?? null
                    ]);
                    return response()->json(['eResponse' => $result]);
                case 'delete':
                    $result = DB::select('SELECT * FROM sp_unidades_recoleccion_delete(?)', [
                        $params['ctrol_recolec']
                    ]);
                    return response()->json(['eResponse' => $result]);
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
        }
        return response()->json(['eResponse' => ['error' => 'Entidad no soportada']], 400);
    }
}
