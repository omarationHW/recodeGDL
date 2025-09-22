<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class CvesOperacionController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Claves de Operación
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|insert|update|delete|get",
     *     "data": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? '';
        $data = $input['data'] ?? [];
        $response = ["success" => false, "message" => "", "data" => null];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('CALL sp_cves_operacion_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get':
                    $id = $data['ctrol_operacion'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $result = DB::select('CALL sp_cves_operacion_get(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'insert':
                    $validator = Validator::make($data, [
                        'cve_operacion' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80',
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception($validator->errors()->first());
                    }
                    $result = DB::select('CALL sp_cves_operacion_insert(?, ?)', [
                        $data['cve_operacion'],
                        $data['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de operación creada correctamente';
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'ctrol_operacion' => 'required|integer',
                        'cve_operacion' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80',
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception($validator->errors()->first());
                    }
                    $result = DB::select('CALL sp_cves_operacion_update(?, ?, ?)', [
                        $data['ctrol_operacion'],
                        $data['cve_operacion'],
                        $data['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de operación actualizada correctamente';
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'delete':
                    $id = $data['ctrol_operacion'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $result = DB::select('CALL sp_cves_operacion_delete(?)', [$id]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de operación eliminada correctamente';
                    break;
                default:
                    throw new \Exception('Acción no soportada');
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json(["eResponse" => $response]);
    }
}
