<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EmpresasController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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
                case 'empresas.list':
                    $response['data'] = DB::select('CALL sp_empresas_list()');
                    $response['success'] = true;
                    break;
                case 'empresas.get':
                    $id = $payload['num_empresa'] ?? null;
                    $ctrol_emp = $payload['ctrol_emp'] ?? null;
                    $response['data'] = DB::select('CALL sp_empresas_get(?, ?)', [$id, $ctrol_emp]);
                    $response['success'] = true;
                    break;
                case 'empresas.create':
                    $validator = Validator::make($payload, [
                        'ctrol_emp' => 'required|integer',
                        'descripcion' => 'required|string|max:80',
                        'representante' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_empresas_create(?, ?, ?)', [
                        $payload['ctrol_emp'],
                        $payload['descripcion'],
                        $payload['representante']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'empresas.update':
                    $validator = Validator::make($payload, [
                        'num_empresa' => 'required|integer',
                        'ctrol_emp' => 'required|integer',
                        'descripcion' => 'required|string|max:80',
                        'representante' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_empresas_update(?, ?, ?, ?)', [
                        $payload['num_empresa'],
                        $payload['ctrol_emp'],
                        $payload['descripcion'],
                        $payload['representante']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'empresas.delete':
                    $validator = Validator::make($payload, [
                        'num_empresa' => 'required|integer',
                        'ctrol_emp' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_empresas_delete(?, ?)', [
                        $payload['num_empresa'],
                        $payload['ctrol_emp']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    $response['data'] = $result[0];
                    break;
                case 'tipos_emp.list':
                    $response['data'] = DB::select('CALL sp_tipos_emp_list()');
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
