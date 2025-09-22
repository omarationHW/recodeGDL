<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class InteresesMttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'interesesmtto.list':
                    $result = DB::select('SELECT * FROM ta_12_intereses ORDER BY axo DESC, mes DESC');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'interesesmtto.create':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer|min:1995',
                        'mes' => 'required|integer|min:1|max:12',
                        'porcentaje' => 'required|numeric|min:0.01',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_interesesmtto_create(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['mes'],
                        $params['porcentaje'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'interesesmtto.update':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer|min:1995',
                        'mes' => 'required|integer|min:1|max:12',
                        'porcentaje' => 'required|numeric|min:0.01',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_interesesmtto_update(?, ?, ?, ?)', [
                        $params['axo'],
                        $params['mes'],
                        $params['porcentaje'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'interesesmtto.delete':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer|min:1995',
                        'mes' => 'required|integer|min:1|max:12'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_interesesmtto_delete(?, ?)', [
                        $params['axo'],
                        $params['mes']
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
