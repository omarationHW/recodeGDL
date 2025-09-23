<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CategoriaMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
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
                    $validator = Validator::make($data, [
                        'categoria' => 'required|integer|min:1|max:12',
                        'descripcion' => 'required|string|max:30',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_categoria_create(?, ?)', [
                        $data['categoria'],
                        strtoupper($data['descripcion'])
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'categoria.update':
                    $validator = Validator::make($data, [
                        'categoria' => 'required|integer|min:1|max:12',
                        'descripcion' => 'required|string|max:30',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_categoria_update(?, ?)', [
                        $data['categoria'],
                        strtoupper($data['descripcion'])
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'categoria.delete':
                    $validator = Validator::make($data, [
                        'categoria' => 'required|integer|min:1|max:12',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_categoria_delete(?)', [
                        $data['categoria']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
