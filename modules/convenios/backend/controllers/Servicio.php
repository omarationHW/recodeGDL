<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ServicioController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Servicios (Obra Pública)
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|delete|show|report",
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
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];
        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_servicio_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'show':
                    $id = $data['servicio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_servicio_show(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'create':
                    $desc = $data['descripcion'] ?? '';
                    $obra94 = $data['serv_obra94'] ?? null;
                    $result = DB::select('SELECT * FROM sp_servicio_create(?, ?)', [$desc, $obra94]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'update':
                    $id = $data['servicio'] ?? null;
                    $desc = $data['descripcion'] ?? '';
                    $obra94 = $data['serv_obra94'] ?? null;
                    $result = DB::select('SELECT * FROM sp_servicio_update(?, ?, ?)', [$id, $desc, $obra94]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'delete':
                    $id = $data['servicio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_servicio_delete(?)', [$id]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'report':
                    $result = DB::select('SELECT * FROM sp_servicio_report()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
