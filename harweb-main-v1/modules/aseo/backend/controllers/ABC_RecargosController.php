<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RecargosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('SELECT * FROM ta_16_recargos WHERE EXTRACT(YEAR FROM aso_mes_recargo) = ? ORDER BY aso_mes_recargo', [
                        $payload['ejercicio'] ?? date('Y')
                    ]);
                    $response['success'] = true;
                    break;
                case 'insert':
                    $validator = Validator::make($payload, [
                        'aso_mes_recargo' => 'required|date',
                        'porc_recargo' => 'required|numeric',
                        'porc_multa' => 'required|numeric'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_insert(?, ?, ?)', [
                        $payload['aso_mes_recargo'],
                        $payload['porc_recargo'],
                        $payload['porc_multa']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'update':
                    $validator = Validator::make($payload, [
                        'aso_mes_recargo' => 'required|date',
                        'porc_recargo' => 'required|numeric',
                        'porc_multa' => 'required|numeric'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_update(?, ?, ?)', [
                        $payload['aso_mes_recargo'],
                        $payload['porc_recargo'],
                        $payload['porc_multa']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'delete':
                    $validator = Validator::make($payload, [
                        'aso_mes_recargo' => 'required|date'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_recargos_delete(?)', [
                        $payload['aso_mes_recargo']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'get':
                    $validator = Validator::make($payload, [
                        'aso_mes_recargo' => 'required|date'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM ta_16_recargos WHERE aso_mes_recargo = ?', [
                        $payload['aso_mes_recargo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data[0] ?? null;
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
