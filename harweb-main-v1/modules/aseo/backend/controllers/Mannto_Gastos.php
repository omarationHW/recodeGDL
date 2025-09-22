<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class GastosController extends Controller
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
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'gastos.list':
                    $result = DB::select('SELECT * FROM ta_16_gastos');
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
                    DB::beginTransaction();
                    DB::statement('CALL sp_gastos_delete_all()');
                    DB::statement('CALL sp_gastos_insert(?, ?, ?, ?)', [
                        $payload['sdzmg'],
                        $payload['porc1_req'],
                        $payload['porc2_embargo'],
                        $payload['porc3_secuestro']
                    ]);
                    DB::commit();
                    $response['success'] = true;
                    $response['message'] = 'Gastos creados correctamente.';
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
                    DB::beginTransaction();
                    DB::statement('CALL sp_gastos_delete_all()');
                    DB::statement('CALL sp_gastos_insert(?, ?, ?, ?)', [
                        $payload['sdzmg'],
                        $payload['porc1_req'],
                        $payload['porc2_embargo'],
                        $payload['porc3_secuestro']
                    ]);
                    DB::commit();
                    $response['success'] = true;
                    $response['message'] = 'Gastos actualizados correctamente.';
                    break;
                case 'gastos.delete':
                    DB::beginTransaction();
                    DB::statement('CALL sp_gastos_delete_all()');
                    DB::commit();
                    $response['success'] = true;
                    $response['message'] = 'Todos los gastos eliminados.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            DB::rollBack();
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
