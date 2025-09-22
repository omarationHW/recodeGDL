<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ColoniasController extends Controller
{
    // API Unificada: /api/execute
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'colonias.list':
                    $result = DB::select('SELECT * FROM colonias_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'colonias.create':
                    $validator = Validator::make($params, [
                        'colonia' => 'required|integer',
                        'descripcion' => 'required|string',
                        'id_rec' => 'required|integer',
                        'id_zona' => 'required|integer',
                        'col_obra94' => 'nullable|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM colonias_create(?,?,?,?,?,?)', [
                        $params['colonia'],
                        $params['descripcion'],
                        $params['id_rec'],
                        $params['id_zona'],
                        $params['col_obra94'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'colonias.update':
                    $validator = Validator::make($params, [
                        'colonia' => 'required|integer',
                        'descripcion' => 'required|string',
                        'id_rec' => 'required|integer',
                        'id_zona' => 'required|integer',
                        'col_obra94' => 'nullable|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM colonias_update(?,?,?,?,?,?)', [
                        $params['colonia'],
                        $params['descripcion'],
                        $params['id_rec'],
                        $params['id_zona'],
                        $params['col_obra94'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'colonias.delete':
                    $validator = Validator::make($params, [
                        'colonia' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM colonias_delete(?)', [
                        $params['colonia']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'colonias.report':
                    $result = DB::select('SELECT * FROM colonias_report()');
                    $response['success'] = true;
                    $response['data'] = $result;
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
