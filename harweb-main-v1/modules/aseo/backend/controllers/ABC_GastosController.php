<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class GastosController extends Controller
{
    // Endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $payload = $request->input('eRequest.payload');
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'list_gastos':
                    $result = DB::select('SELECT * FROM ta_16_gastos ORDER BY sdzmg DESC');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'insert_gasto':
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
                    DB::statement('CALL sp_gastos_insert(?, ?, ?, ?)', [
                        $payload['sdzmg'],
                        $payload['porc1_req'],
                        $payload['porc2_embargo'],
                        $payload['porc3_secuestro']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Gasto insertado correctamente.';
                    break;
                case 'update_gasto':
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
                    DB::statement('CALL sp_gastos_update(?, ?, ?, ?)', [
                        $payload['sdzmg'],
                        $payload['porc1_req'],
                        $payload['porc2_embargo'],
                        $payload['porc3_secuestro']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Gasto actualizado correctamente.';
                    break;
                case 'delete_gasto':
                    $validator = Validator::make($payload, [
                        'sdzmg' => 'required|numeric|min:0.01'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::statement('CALL sp_gastos_delete(?)', [
                        $payload['sdzmg']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Gasto eliminado correctamente.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
