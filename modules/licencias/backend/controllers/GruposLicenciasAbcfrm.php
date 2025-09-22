<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute endpoint.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'list_grupos_licencias':
                    $descripcion = $params['descripcion'] ?? '';
                    $result = DB::select('SELECT * FROM sp_list_grupos_licencias(?)', [$descripcion]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_grupo_licencia':
                    $id = $params['id'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_grupo_licencia(?)', [$id]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'insert_grupo_licencia':
                    $descripcion = $params['descripcion'] ?? '';
                    $result = DB::select('SELECT * FROM sp_insert_grupo_licencia(?)', [$descripcion]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'update_grupo_licencia':
                    $id = $params['id'] ?? null;
                    $descripcion = $params['descripcion'] ?? '';
                    $result = DB::select('SELECT * FROM sp_update_grupo_licencia(?, ?)', [$id, $descripcion]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'delete_grupo_licencia':
                    $id = $params['id'] ?? null;
                    $result = DB::select('SELECT * FROM sp_delete_grupo_licencia(?)', [$id]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
