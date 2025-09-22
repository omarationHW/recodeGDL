<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar procedimientos almacenados
     * Entrada: {
     *   "eRequest": {
     *     "procedure": "nombre_del_sp",
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
        if (!$input || !isset($input['procedure'])) {
            return response()->json(['eResponse' => ['error' => 'Procedure not specified']], 400);
        }
        $procedure = $input['procedure'];
        $params = isset($input['params']) ? $input['params'] : [];

        // Map de procedimientos permitidos
        $allowedProcedures = [
            'sp_get_datosrcm',
            'sp_get_passwords',
            'sp_get_descpens',
            'sp_get_datosrcmadic',
            'sp_get_bonifrcm',
            'sp_get_descrec',
            'sp_get_datosrcmhis',
            'sp_get_cementerios',
            'sp_get_datosrcmextra',
            'sp_get_pagosrcm',
            'sp_get_constot'
        ];
        if (!in_array($procedure, $allowedProcedures)) {
            return response()->json(['eResponse' => ['error' => 'Procedure not allowed']], 403);
        }

        // Construir llamada dinámica
        $paramStr = '';
        $bindings = [];
        if (!empty($params)) {
            $paramStr = implode(', ', array_map(function($k) { return ':' . $k; }, array_keys($params)));
            $bindings = $params;
        }
        $sql = "CALL $procedure($paramStr)";
        try {
            $result = DB::select($sql, $bindings);
            return response()->json(['eResponse' => $result]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }
}
