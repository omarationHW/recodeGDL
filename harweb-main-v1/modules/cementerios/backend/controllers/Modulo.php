<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                case 'getCurrentTime':
                    $result = DB::select('SELECT current_time FROM systables LIMIT 1');
                    $response['success'] = true;
                    $response['data'] = $result[0]->current_time ?? null;
                    break;
                case 'getUserByCredentials':
                    $usuario = $params['usuario'] ?? '';
                    $clave = $params['clave'] ?? '';
                    $result = DB::select('SELECT * FROM sp_valida_usuario(?, ?)', [$usuario, $clave]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getUserDetails':
                    $usuario = $params['usuario'] ?? '';
                    $result = DB::select('SELECT * FROM sp_get_usuario_detalle(?)', [$usuario]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'checkNewVersion':
                    $proyecto = $params['proyecto'] ?? '';
                    $version = $params['version'] ?? '';
                    $result = DB::select('SELECT * FROM sp_hay_nueva_version(?, ?)', [$proyecto, $version]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getVersionDetails':
                    $proyecto = $params['proyecto'] ?? '';
                    $version = $params['version'] ?? '';
                    $result = DB::select('SELECT * FROM sp_get_version_detalle(?, ?)', [$proyecto, $version]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
