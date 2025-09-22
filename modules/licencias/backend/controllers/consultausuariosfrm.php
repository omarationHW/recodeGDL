<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
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
                case 'get_dependencias':
                    $result = DB::select('SELECT * FROM get_dependencias()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_deptos_by_dependencia':
                    $id_dependencia = $params['id_dependencia'] ?? null;
                    if (!$id_dependencia) {
                        throw new \Exception('id_dependencia is required');
                    }
                    $result = DB::select('SELECT * FROM get_deptos_by_dependencia(?)', [$id_dependencia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'consulta_usuario_por_usuario':
                    $usuario = $params['usuario'] ?? null;
                    if (!$usuario) {
                        throw new \Exception('usuario is required');
                    }
                    $result = DB::select('SELECT * FROM consulta_usuario_por_usuario(?)', [$usuario]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'consulta_usuario_por_nombre':
                    $nombre = $params['nombre'] ?? null;
                    if (!$nombre) {
                        throw new \Exception('nombre is required');
                    }
                    $result = DB::select('SELECT * FROM consulta_usuario_por_nombre(?)', [$nombre]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'consulta_usuario_por_depto':
                    $id_dependencia = $params['id_dependencia'] ?? null;
                    $cvedepto = $params['cvedepto'] ?? null;
                    if (!$id_dependencia || !$cvedepto) {
                        throw new \Exception('id_dependencia and cvedepto are required');
                    }
                    $result = DB::select('SELECT * FROM consulta_usuario_por_depto(?, ?)', [$id_dependencia, $cvedepto]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
