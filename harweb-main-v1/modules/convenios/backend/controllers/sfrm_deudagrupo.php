<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DeudaGrupoController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre deudagrupo
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|delete|show",
     *     "data": { ... }
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
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_deudagrupo_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'show':
                    $id = $data['id'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $result = DB::select('SELECT * FROM sp_deudagrupo_show(?)', [$id]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'create':
                    $nombre = $data['nombre'] ?? null;
                    $descripcion = $data['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_deudagrupo_create(?, ?)', [$nombre, $descripcion]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    $eResponse['message'] = 'Registro creado correctamente';
                    break;
                case 'update':
                    $id = $data['id'] ?? null;
                    $nombre = $data['nombre'] ?? null;
                    $descripcion = $data['descripcion'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $result = DB::select('SELECT * FROM sp_deudagrupo_update(?, ?, ?)', [$id, $nombre, $descripcion]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    $eResponse['message'] = 'Registro actualizado correctamente';
                    break;
                case 'delete':
                    $id = $data['id'] ?? null;
                    if (!$id) throw new \Exception('ID requerido');
                    $result = DB::select('SELECT * FROM sp_deudagrupo_delete(?)', [$id]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                default:
                    throw new \Exception('Acción no soportada');
            }
        } catch (\Exception $e) {
            Log::error('DeudaGrupoController error: ' . $e->getMessage());
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
