<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ActualizaContController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : ($params['user_id'] ?? null);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'getDiferencias':
                    $data = DB::select('SELECT * FROM sp_get_diferencias_contratos()');
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'actualizarContratos':
                    $result = DB::select('SELECT * FROM sp_actualiza_contratos(?)', [$userId]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getTotalesActualizacion':
                    $result = DB::select('SELECT * FROM sp_totales_actualizacion(?)', [$userId]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('Error en ActualizaContController: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
