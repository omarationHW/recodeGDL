<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ManntoOperacionesController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Claves de Operación
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|delete|check_usage",
     *     "data": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $req = $request->input('eRequest');
        $action = $req['action'] ?? '';
        $data = $req['data'] ?? [];
        $response = ["success" => false, "message" => "", "data" => null];
        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp16_operaciones_list()');
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'create':
                    $cve = $data['cve_operacion'] ?? '';
                    $desc = $data['descripcion'] ?? '';
                    $result = DB::select('SELECT * FROM sp16_operaciones_create(?, ?)', [$cve, $desc]);
                    $response = $result[0];
                    break;
                case 'update':
                    $cve = $data['cve_operacion'] ?? '';
                    $desc = $data['descripcion'] ?? '';
                    $result = DB::select('SELECT * FROM sp16_operaciones_update(?, ?)', [$cve, $desc]);
                    $response = $result[0];
                    break;
                case 'delete':
                    $ctrol = $data['ctrol_operacion'] ?? null;
                    $result = DB::select('SELECT * FROM sp16_operaciones_delete(?)', [$ctrol]);
                    $response = $result[0];
                    break;
                case 'check_usage':
                    $ctrol = $data['ctrol_operacion'] ?? null;
                    $result = DB::select('SELECT * FROM sp16_operaciones_check_usage(?)', [$ctrol]);
                    $response = $result[0];
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no soportada", "data" => null];
            }
        } catch (\Exception $ex) {
            $response = ["success" => false, "message" => $ex->getMessage(), "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }
}
