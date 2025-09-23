<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ElaboroConvenioController extends Controller
{
    // Endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('SELECT * FROM sp_elaboro_convenio_list()');
                    $response['success'] = true;
                    break;
                case 'create':
                    $validator = Validator::make($params, [
                        'id_rec' => 'required|integer',
                        'id_usu_titular' => 'required|integer',
                        'iniciales_titular' => 'required|string|max:10',
                        'id_usu_elaboro' => 'required|integer',
                        'iniciales_elaboro' => 'required|string|max:10'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_elaboro_convenio_create(?,?,?,?,?)', [
                        $params['id_rec'],
                        $params['id_usu_titular'],
                        $params['iniciales_titular'],
                        $params['id_usu_elaboro'],
                        $params['iniciales_elaboro']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'update':
                    $validator = Validator::make($params, [
                        'id_control' => 'required|integer',
                        'id_rec' => 'required|integer',
                        'id_usu_titular' => 'required|integer',
                        'iniciales_titular' => 'required|string|max:10',
                        'id_usu_elaboro' => 'required|integer',
                        'iniciales_elaboro' => 'required|string|max:10'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_elaboro_convenio_update(?,?,?,?,?,?)', [
                        $params['id_control'],
                        $params['id_rec'],
                        $params['id_usu_titular'],
                        $params['iniciales_titular'],
                        $params['id_usu_elaboro'],
                        $params['iniciales_elaboro']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'delete':
                    $validator = Validator::make($params, [
                        'id_control' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_elaboro_convenio_delete(?)', [
                        $params['id_control']
                    ]);
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
