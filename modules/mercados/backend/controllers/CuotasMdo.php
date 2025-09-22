<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CuotasMdoController extends Controller
{
    // Endpoint único para eRequest/eResponse
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
                case 'list_cuotas':
                    $response['data'] = DB::select('CALL sp_cuotasmdo_list(?)', [
                        $params['axo'] ?? date('Y')
                    ]);
                    $response['success'] = true;
                    break;
                case 'create_cuota':
                    $validator = Validator::make($params, [
                        'axo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'clave_cuota' => 'required|integer',
                        'importe_cuota' => 'required|numeric',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cuotasmdo_create(?,?,?,?,?,?)', [
                        $params['axo'],
                        $params['categoria'],
                        $params['seccion'],
                        $params['clave_cuota'],
                        $params['importe_cuota'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'update_cuota':
                    $validator = Validator::make($params, [
                        'id_cuotas' => 'required|integer',
                        'axo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'clave_cuota' => 'required|integer',
                        'importe_cuota' => 'required|numeric',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('CALL sp_cuotasmdo_update(?,?,?,?,?,?,?)', [
                        $params['id_cuotas'],
                        $params['axo'],
                        $params['categoria'],
                        $params['seccion'],
                        $params['clave_cuota'],
                        $params['importe_cuota'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'delete_cuota':
                    $validator = Validator::make($params, [
                        'id_cuotas' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::statement('CALL sp_cuotasmdo_delete(?)', [
                        $params['id_cuotas']
                    ]);
                    $response['success'] = true;
                    break;
                case 'get_categorias':
                    $response['data'] = DB::select('CALL sp_categorias_list()');
                    $response['success'] = true;
                    break;
                case 'get_secciones':
                    $response['data'] = DB::select('CALL sp_secciones_list()');
                    $response['success'] = true;
                    break;
                case 'get_claves_cuota':
                    $response['data'] = DB::select('CALL sp_clavescuota_list()');
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
