<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ElaboroMnttoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre el catálogo de Elaboro Oficio
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|delete|show",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'list':
                    $data = DB::select('SELECT * FROM ta_17_elaboroficio ORDER BY id_control DESC');
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'show':
                    $id = $params['id_control'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $data = DB::selectOne('SELECT * FROM ta_17_elaboroficio WHERE id_control = ?', [$id]);
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'create':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer',
                        'id_usu_titular' => 'required|integer',
                        'iniciales_titular' => 'required|string|max:10',
                        'id_usu_elaboro' => 'required|integer',
                        'iniciales_elaboro' => 'required|string|max:10'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception($validator->errors()->first());
                    }
                    $result = DB::select('SELECT * FROM sp_elaboro_mntto_create(?,?,?,?,?) as id_control', [
                        $params['id_rec'],
                        $params['id_usu_titular'],
                        $params['iniciales_titular'],
                        $params['id_usu_elaboro'],
                        $params['iniciales_elaboro']
                    ]);
                    $response = ["success" => true, "message" => "Registro creado", "data" => $result[0]->id_control];
                    break;
                case 'update':
                    $validator = Validator::make($params, [
                        'id_control' => 'required|integer',
                        'id_rec' => 'required|integer',
                        'id_usu_titular' => 'required|integer',
                        'iniciales_titular' => 'required|string|max:10',
                        'id_usu_elaboro' => 'required|integer',
                        'iniciales_elaboro' => 'required|string|max:10'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception($validator->errors()->first());
                    }
                    $result = DB::select('SELECT * FROM sp_elaboro_mntto_update(?,?,?,?,?,?) as updated', [
                        $params['id_control'],
                        $params['id_rec'],
                        $params['id_usu_titular'],
                        $params['iniciales_titular'],
                        $params['id_usu_elaboro'],
                        $params['iniciales_elaboro']
                    ]);
                    $response = ["success" => true, "message" => "Registro actualizado", "data" => $result[0]->updated];
                    break;
                case 'delete':
                    $id = $params['id_control'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $result = DB::select('SELECT * FROM sp_elaboro_mntto_delete(?) as deleted', [$id]);
                    $response = ["success" => true, "message" => "Registro eliminado", "data" => $result[0]->deleted];
                    break;
                case 'titular_info':
                    // Consulta de datos de titular y elabora
                    $id_rec = $params['id_rec'] ?? null;
                    $id_usu_titular = $params['id_usu_titular'] ?? null;
                    $id_usu_elaboro = $params['id_usu_elaboro'] ?? null;
                    if (!$id_rec || !$id_usu_titular || !$id_usu_elaboro) throw new \Exception('Parámetros requeridos');
                    $data = DB::select('SELECT * FROM sp_elaboro_mntto_titular_info(?,?,?)', [
                        $id_rec, $id_usu_titular, $id_usu_elaboro
                    ]);
                    $response = ["success" => true, "data" => $data];
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
