<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ServiciosMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'servicios_list':
                    $response['data'] = DB::select('SELECT * FROM ta_17_servicios ORDER BY servicio');
                    $response['success'] = true;
                    break;
                case 'servicios_get':
                    $id = $params['servicio'] ?? null;
                    $response['data'] = DB::selectOne('SELECT * FROM ta_17_servicios WHERE servicio = ?', [$id]);
                    $response['success'] = true;
                    break;
                case 'servicios_create':
                    $validator = Validator::make($params, [
                        'servicio' => 'required|integer',
                        'descripcion' => 'required|string|max:255',
                        'serv_obra94' => 'nullable|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_servicios_insert(?, ?, ?)', [
                        $params['servicio'],
                        $params['descripcion'],
                        $params['serv_obra94'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'servicios_update':
                    $validator = Validator::make($params, [
                        'servicio' => 'required|integer',
                        'descripcion' => 'required|string|max:255',
                        'serv_obra94' => 'nullable|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_servicios_update(?, ?, ?)', [
                        $params['servicio'],
                        $params['descripcion'],
                        $params['serv_obra94'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'servicios_delete':
                    $id = $params['servicio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_servicios_delete(?)', [$id]);
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
