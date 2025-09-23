<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class GastosController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'gastos.list':
                    $result = DB::select('SELECT * FROM ta_16_gastos ORDER BY sdzmg DESC LIMIT 1');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'gastos.create':
                    $validator = Validator::make($payload, [
                        'sdzmg' => 'required|numeric|min:0.01',
                        'porc1_req' => 'required|numeric|min:0.01',
                        'porc2_embargo' => 'required|numeric|min:0.01',
                        'porc3_secuestro' => 'required|numeric|min:0.01',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    // Solo puede haber un registro, así que primero borra
                    DB::statement('CALL sp_gastos_delete_all()');
                    DB::statement('CALL sp_gastos_insert(?, ?, ?, ?)', [
                        $payload['sdzmg'],
                        $payload['porc1_req'],
                        $payload['porc2_embargo'],
                        $payload['porc3_secuestro']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Gastos creados correctamente';
                    break;
                case 'gastos.update':
                    $validator = Validator::make($payload, [
                        'sdzmg' => 'required|numeric|min:0.01',
                        'porc1_req' => 'required|numeric|min:0.01',
                        'porc2_embargo' => 'required|numeric|min:0.01',
                        'porc3_secuestro' => 'required|numeric|min:0.01',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    // Solo puede haber un registro, así que primero borra
                    DB::statement('CALL sp_gastos_delete_all()');
                    DB::statement('CALL sp_gastos_insert(?, ?, ?, ?)', [
                        $payload['sdzmg'],
                        $payload['porc1_req'],
                        $payload['porc2_embargo'],
                        $payload['porc3_secuestro']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Gastos actualizados correctamente';
                    break;
                case 'gastos.delete':
                    DB::statement('CALL sp_gastos_delete_all()');
                    $response['success'] = true;
                    $response['message'] = 'Gastos eliminados correctamente';
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
