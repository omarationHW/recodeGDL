<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ModuloBDController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del módulo ModuloBD
     * Entrada: eRequest (objeto JSON con acción y parámetros)
     * Salida: eResponse (objeto JSON con resultado, error, datos)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'error' => null,
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getTipos':
                    $result = DB::select('SELECT * FROM sp_get_tipos()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'addTipo':
                    $validator = Validator::make($params, [
                        'descripcion' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['error'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_add_tipo(?)', [$params['descripcion']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'updateTipo':
                    $validator = Validator::make($params, [
                        'tipo' => 'required|integer',
                        'descripcion' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['error'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_tipo(?, ?)', [$params['tipo'], $params['descripcion']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'deleteTipo':
                    $validator = Validator::make($params, [
                        'tipo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['error'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_delete_tipo(?)', [$params['tipo']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                // ... otros casos para SubTipo, Colonias, Servicios, Calles, etc.
                default:
                    $eResponse['error'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
