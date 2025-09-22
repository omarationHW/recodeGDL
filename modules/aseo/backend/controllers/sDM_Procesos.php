<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ProcesosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Procesos
     * Entrada: {
     *   "eRequest": {
     *      "action": "list|create|update|delete|get",
     *      "data": { ... }
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
        $data = $eRequest['data'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM procesos_listar()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get':
                    $id = $data['id'] ?? null;
                    if (!$id) {
                        throw new \Exception('ID requerido');
                    }
                    $result = DB::select('SELECT * FROM procesos_obtener(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'create':
                    $nombre = $data['nombre'] ?? null;
                    $descripcion = $data['descripcion'] ?? null;
                    if (!$nombre) {
                        throw new \Exception('Nombre requerido');
                    }
                    $result = DB::select('SELECT * FROM procesos_crear(?, ?)', [$nombre, $descripcion]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'update':
                    $id = $data['id'] ?? null;
                    $nombre = $data['nombre'] ?? null;
                    $descripcion = $data['descripcion'] ?? null;
                    if (!$id || !$nombre) {
                        throw new \Exception('ID y Nombre requeridos');
                    }
                    $result = DB::select('SELECT * FROM procesos_actualizar(?, ?, ?)', [$id, $nombre, $descripcion]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'delete':
                    $id = $data['id'] ?? null;
                    if (!$id) {
                        throw new \Exception('ID requerido');
                    }
                    $result = DB::select('SELECT * FROM procesos_eliminar(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                default:
                    throw new \Exception('Acción no soportada');
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}
