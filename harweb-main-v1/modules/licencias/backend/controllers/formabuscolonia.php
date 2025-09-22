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
                case 'buscar_colonias':
                    // params: { filtro: string|null }
                    $filtro = isset($params['filtro']) ? $params['filtro'] : '';
                    $result = DB::select('SELECT * FROM sp_buscar_colonias(?, ?)', [39, $filtro]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'obtener_colonia_seleccionada':
                    // params: { colonia: string }
                    $colonia = isset($params['colonia']) ? $params['colonia'] : '';
                    $result = DB::select('SELECT * FROM sp_obtener_colonia_seleccionada(?, ?)', [39, $colonia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = 'Error interno del servidor';
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
