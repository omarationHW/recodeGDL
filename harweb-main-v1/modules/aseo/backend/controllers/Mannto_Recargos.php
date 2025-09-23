<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class RecargosController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     * POST /api/execute
     */
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
                case 'recargos.list':
                    $year = $params['year'] ?? date('Y');
                    $result = DB::select('SELECT * FROM sp_recargos_list(?)', [$year]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos.create':
                    $validator = Validator::make($params, [
                        'year' => 'required|integer|min:1900',
                        'month' => 'required|integer|min:1|max:12',
                        'porc_recargo' => 'required|numeric|min:0',
                        'porc_multa' => 'required|numeric|min:0'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_create(?,?,?,?)', [
                        $params['year'], $params['month'], $params['porc_recargo'], $params['porc_multa']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'recargos.update':
                    $validator = Validator::make($params, [
                        'year' => 'required|integer|min:1900',
                        'month' => 'required|integer|min:1|max:12',
                        'porc_recargo' => 'required|numeric|min:0',
                        'porc_multa' => 'required|numeric|min:0'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_update(?,?,?,?)', [
                        $params['year'], $params['month'], $params['porc_recargo'], $params['porc_multa']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'recargos.delete':
                    $validator = Validator::make($params, [
                        'year' => 'required|integer|min:1900',
                        'month' => 'required|integer|min:1|max:12'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_delete(?,?)', [
                        $params['year'], $params['month']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
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
