<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'get_grupos_licencias':
                    $result = DB::select('SELECT * FROM get_grupos_licencias(?)', [
                        $params['descripcion'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'insert_grupo_licencia':
                    $result = DB::select('SELECT * FROM insert_grupo_licencia(?)', [
                        $params['descripcion']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'update_grupo_licencia':
                    $result = DB::select('SELECT * FROM update_grupo_licencia(?, ?)', [
                        $params['id'],
                        $params['descripcion']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'delete_grupo_licencia':
                    $result = DB::select('SELECT * FROM delete_grupo_licencia(?)', [
                        $params['id']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'get_licencias_disponibles':
                    $result = DB::select('SELECT * FROM get_licencias_disponibles(?, ?, ?)', [
                        $params['grupo_id'],
                        $params['actividad'] ?? null,
                        $params['id_giro'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_licencias_grupo':
                    $result = DB::select('SELECT * FROM get_licencias_grupo(?, ?)', [
                        $params['grupo_id'],
                        $params['actividad'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'add_licencias_to_grupo':
                    $result = DB::select('SELECT * FROM add_licencias_to_grupo(?, ?)', [
                        $params['grupo_id'],
                        '{' . implode(',', $params['licencias']) . '}'
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'remove_licencias_from_grupo':
                    $result = DB::select('SELECT * FROM remove_licencias_from_grupo(?, ?)', [
                        $params['grupo_id'],
                        '{' . implode(',', $params['licencias']) . '}'
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0];
                    break;
                case 'get_giros':
                    $result = DB::select('SELECT * FROM get_giros()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
