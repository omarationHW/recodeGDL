<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class ManntoTiposAseoController extends Controller
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
                    $result = DB::select('SELECT * FROM sp_cat_tipos_aseo_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get':
                    $tipo = $data['tipo_aseo'] ?? null;
                    $result = DB::select('SELECT * FROM sp_cat_tipos_aseo_get(?)', [$tipo]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'tipo_aseo' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80',
                        'cta_aplicacion' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_tipos_aseo_create(?, ?, ?)', [
                        $data['tipo_aseo'],
                        $data['descripcion'],
                        $data['cta_aplicacion']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'tipo_aseo' => 'required|string|max:1',
                        'descripcion' => 'required|string|max:80',
                        'cta_aplicacion' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_cat_tipos_aseo_update(?, ?, ?)', [
                        $data['tipo_aseo'],
                        $data['descripcion'],
                        $data['cta_aplicacion']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'delete':
                    $tipo = $data['tipo_aseo'] ?? null;
                    $result = DB::select('SELECT * FROM sp_cat_tipos_aseo_delete(?)', [$tipo]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'validate_cta_aplicacion':
                    $cta = $data['cta_aplicacion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_cat_cta_aplicacion_exists(?)', [$cta]);
                    $response['success'] = $result[0]->exists;
                    $response['data'] = $result[0];
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
