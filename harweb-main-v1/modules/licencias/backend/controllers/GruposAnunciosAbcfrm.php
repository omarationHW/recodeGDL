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
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'anuncios_grupos_list':
                    $result = DB::select('SELECT * FROM anuncios_grupos_list(:p_descripcion)', [
                        'p_descripcion' => $params['descripcion'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'anuncios_grupos_get':
                    $result = DB::select('SELECT * FROM anuncios_grupos_get(:p_id)', [
                        'p_id' => $params['id']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result ? $result[0] : null;
                    break;
                case 'anuncios_grupos_insert':
                    $result = DB::select('SELECT * FROM anuncios_grupos_insert(:p_descripcion)', [
                        'p_descripcion' => $params['descripcion']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result ? $result[0] : null;
                    $eResponse['message'] = 'Grupo de anuncio creado correctamente.';
                    break;
                case 'anuncios_grupos_update':
                    $result = DB::select('SELECT * FROM anuncios_grupos_update(:p_id, :p_descripcion)', [
                        'p_id' => $params['id'],
                        'p_descripcion' => $params['descripcion']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result ? $result[0] : null;
                    $eResponse['message'] = 'Grupo de anuncio actualizado correctamente.';
                    break;
                case 'anuncios_grupos_delete':
                    $result = DB::select('SELECT * FROM anuncios_grupos_delete(:p_id)', [
                        'p_id' => $params['id']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result ? $result[0] : null;
                    $eResponse['message'] = 'Grupo de anuncio eliminado correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado.';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
