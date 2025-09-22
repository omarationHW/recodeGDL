<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

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
                case 'buscar_calles':
                    // params: { filtro: string }
                    $filtro = isset($params['filtro']) ? $params['filtro'] : '';
                    $result = DB::select('SELECT * FROM sp_buscar_calles(?)', [$filtro]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'listar_calles':
                    $result = DB::select('SELECT * FROM sp_listar_calles()');
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
