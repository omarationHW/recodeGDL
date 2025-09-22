<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CategoriaController extends Controller
{
    // API Unificada: /api/execute
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'categoria.list':
                    $result = DB::select('SELECT * FROM sp_categoria_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'categoria.create':
                    $validator = Validator::make($params, [
                        'categoria' => 'required|integer',
                        'descripcion' => 'required|string|max:30',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_categoria_create(?, ?)', [
                        $params['categoria'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'categoria.update':
                    $validator = Validator::make($params, [
                        'categoria' => 'required|integer',
                        'descripcion' => 'required|string|max:30',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_categoria_update(?, ?)', [
                        $params['categoria'],
                        $params['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'categoria.delete':
                    $validator = Validator::make($params, [
                        'categoria' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_categoria_delete(?)', [
                        $params['categoria']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                default:
                    $response['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
