<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CuotasEnergiaController extends Controller
{
    // API endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('CALL sp_cuotas_energia_list()');
                    $response['success'] = true;
                    break;
                case 'create':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer',
                        'importe' => 'required|numeric|min:0.000001',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cuotas_energia_create(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['periodo'],
                        $params['importe'],
                        $userId
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'update':
                    $validator = Validator::make($params, [
                        'id_kilowhatts' => 'required|integer',
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer',
                        'importe' => 'required|numeric|min:0.000001',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cuotas_energia_update(?, ?, ?, ?, ?)', [
                        $params['id_kilowhatts'],
                        $params['axo'],
                        $params['periodo'],
                        $params['importe'],
                        $userId
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'delete':
                    $validator = Validator::make($params, [
                        'id_kilowhatts' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cuotas_energia_delete(?)', [
                        $params['id_kilowhatts']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get':
                    $validator = Validator::make($params, [
                        'id_kilowhatts' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cuotas_energia_get(?)', [
                        $params['id_kilowhatts']
                    ]);
                    $response['data'] = $result ? $result[0] : null;
                    $response['success'] = true;
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
