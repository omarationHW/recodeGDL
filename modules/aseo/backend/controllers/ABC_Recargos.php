<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RecargosController extends Controller
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
                case 'recargos.list':
                    $year = $params['year'] ?? null;
                    $result = DB::select('SELECT * FROM sp_recargos_list(?)', [$year]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'recargos.create':
                    $validator = Validator::make($params, [
                        'aso_mes_recargo' => 'required|date',
                        'porc_recargo' => 'required|numeric',
                        'porc_multa' => 'required|numeric'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_create(?, ?, ?)', [
                        $params['aso_mes_recargo'],
                        $params['porc_recargo'],
                        $params['porc_multa']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'recargos.update':
                    $validator = Validator::make($params, [
                        'aso_mes_recargo' => 'required|date',
                        'porc_recargo' => 'required|numeric',
                        'porc_multa' => 'required|numeric'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_update(?, ?, ?)', [
                        $params['aso_mes_recargo'],
                        $params['porc_recargo'],
                        $params['porc_multa']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'recargos.delete':
                    $validator = Validator::make($params, [
                        'aso_mes_recargo' => 'required|date'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_delete(?)', [
                        $params['aso_mes_recargo']
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
