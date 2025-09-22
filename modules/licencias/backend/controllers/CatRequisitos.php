<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CatRequisitosController extends Controller
{
    /**
     * Ejecuta operaciones sobre Catálogo de Requisitos vía API unificada.
     * Endpoint: /api/execute
     * Entrada: {
     *   "eRequest": {
     *     "module": "cat_requisitos",
     *     "action": "list|create|update|delete|search|print",
     *     "data": {...}
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? '';
        $data = $eRequest['data'] ?? [];
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_cat_requisitos_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'search':
                    $desc = $data['descripcion'] ?? '';
                    $result = DB::select('SELECT * FROM sp_cat_requisitos_search(?)', [$desc]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'descripcion' => 'required|string|max:255'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_requisitos_create(?)', [$data['descripcion']]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'req' => 'required|integer',
                        'descripcion' => 'required|string|max:255'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_requisitos_update(?, ?)', [$data['req'], $data['descripcion']]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'delete':
                    $validator = Validator::make($data, [
                        'req' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_requisitos_delete(?)', [$data['req']]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'print':
                    // Devuelve datos para impresión (puede ser PDF generado en frontend)
                    $result = DB::select('SELECT * FROM sp_cat_requisitos_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(["eResponse" => $response]);
    }
}
