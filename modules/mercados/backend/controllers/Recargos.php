<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RecargosController extends Controller
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
                case 'recargos.list':
                    $response['data'] = DB::select('CALL sp_recargos_list()');
                    $response['success'] = true;
                    break;
                case 'recargos.create':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer',
                        'porcentaje' => 'required|numeric',
                        'usuario_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_recargos_create(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['periodo'],
                        $params['porcentaje'],
                        $params['usuario_id']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'recargos.update':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer',
                        'porcentaje' => 'required|numeric',
                        'usuario_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_recargos_update(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['periodo'],
                        $params['porcentaje'],
                        $params['usuario_id']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'recargos.delete':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_recargos_delete(?, ?)', [
                        $params['axo'],
                        $params['periodo']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
