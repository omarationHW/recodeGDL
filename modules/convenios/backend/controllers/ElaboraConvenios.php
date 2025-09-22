<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ElaboraConveniosController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'list':
                return $this->list($params);
            case 'create':
                return $this->create($params, $userId);
            case 'update':
                return $this->update($params, $userId);
            case 'delete':
                return $this->delete($params, $userId);
            case 'get':
                return $this->get($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                ], 400);
        }
    }

    /**
     * Listar todos los registros de quienes elaboran convenios
     */
    public function list($params)
    {
        $result = DB::select('SELECT * FROM sp_elabora_convenios_list()');
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Crear un nuevo registro
     */
    public function create($params, $userId)
    {
        $validator = Validator::make($params, [
            'id_rec' => 'required|integer',
            'id_usu_titular' => 'required|integer',
            'iniciales_titular' => 'required|string|max:10',
            'id_usu_elaboro' => 'required|integer',
            'iniciales_elaboro' => 'required|string|max:10',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_elabora_convenios_create(?,?,?,?,?,?)', [
            $params['id_rec'],
            $params['id_usu_titular'],
            $params['iniciales_titular'],
            $params['id_usu_elaboro'],
            $params['iniciales_elaboro'],
            $userId
        ]);
        return response()->json([
            'success' => true,
            'data' => $result[0] ?? null
        ]);
    }

    /**
     * Actualizar un registro existente
     */
    public function update($params, $userId)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer',
            'id_rec' => 'required|integer',
            'id_usu_titular' => 'required|integer',
            'iniciales_titular' => 'required|string|max:10',
            'id_usu_elaboro' => 'required|integer',
            'iniciales_elaboro' => 'required|string|max:10',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_elabora_convenios_update(?,?,?,?,?,?,?)', [
            $params['id_control'],
            $params['id_rec'],
            $params['id_usu_titular'],
            $params['iniciales_titular'],
            $params['id_usu_elaboro'],
            $params['iniciales_elaboro'],
            $userId
        ]);
        return response()->json([
            'success' => true,
            'data' => $result[0] ?? null
        ]);
    }

    /**
     * Eliminar un registro
     */
    public function delete($params, $userId)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_elabora_convenios_delete(?,?)', [
            $params['id_control'],
            $userId
        ]);
        return response()->json([
            'success' => true,
            'data' => $result[0] ?? null
        ]);
    }

    /**
     * Obtener un registro específico
     */
    public function get($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }
        $result = DB::select('SELECT * FROM sp_elabora_convenios_get(?)', [
            $params['id_control']
        ]);
        return response()->json([
            'success' => true,
            'data' => $result[0] ?? null
        ]);
    }
}
