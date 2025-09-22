<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ManntoUndRecolecController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'list':
                    $ejercicio = $data['ejercicio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_cat_unidades_list(?)', [$ejercicio]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'insert':
                    $validator = Validator::make($data, [
                        'ejercicio' => 'required|integer',
                        'cve' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80',
                        'costo' => 'required|numeric',
                        'costo_exed' => 'required|numeric'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_unidades_insert(?,?,?,?,?)', [
                        $data['ejercicio'],
                        $data['cve'],
                        $data['descripcion'],
                        $data['costo'],
                        $data['costo_exed']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'ctrol_recolec' => 'required|integer',
                        'descripcion' => 'required|string|max:80',
                        'costo' => 'required|numeric',
                        'costo_exed' => 'required|numeric'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_unidades_update(?,?,?,?)', [
                        $data['ctrol_recolec'],
                        $data['descripcion'],
                        $data['costo'],
                        $data['costo_exed']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'delete':
                    $validator = Validator::make($data, [
                        'ctrol_recolec' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_unidades_delete(?)', [
                        $data['ctrol_recolec']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'get':
                    $ctrol_recolec = $data['ctrol_recolec'] ?? null;
                    $result = DB::select('SELECT * FROM sp_cat_unidades_get(?)', [$ctrol_recolec]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
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
