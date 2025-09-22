<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class SubTipoController extends Controller
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
                case 'list_subtipos':
                    $result = DB::select('SELECT * FROM sp_subtipo_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_subtipo':
                    $id = $params['id'] ?? null;
                    $result = DB::select('SELECT * FROM sp_subtipo_get(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'create_subtipo':
                    $result = DB::select('SELECT * FROM sp_subtipo_create(?,?,?,?,?)', [
                        $params['tipo'],
                        $params['subtipo'],
                        $params['desc_subtipo'],
                        $params['cuenta_ingreso'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'update_subtipo':
                    $result = DB::select('SELECT * FROM sp_subtipo_update(?,?,?,?,?)', [
                        $params['tipo'],
                        $params['subtipo'],
                        $params['desc_subtipo'],
                        $params['cuenta_ingreso'],
                        $params['id_usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'delete_subtipo':
                    $result = DB::select('SELECT * FROM sp_subtipo_delete(?,?)', [
                        $params['tipo'],
                        $params['subtipo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0];
                    break;
                case 'last_subtipo_by_tipo':
                    $tipo = $params['tipo'] ?? null;
                    $result = DB::select('SELECT * FROM sp_subtipo_last_by_tipo(?)', [$tipo]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
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
