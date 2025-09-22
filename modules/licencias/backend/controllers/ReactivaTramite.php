<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

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
                case 'get_tramite':
                    $id_tramite = $params['id_tramite'] ?? null;
                    if (!$id_tramite) {
                        throw new \Exception('id_tramite es requerido');
                    }
                    $tramite = DB::select('SELECT * FROM get_tramite(:id_tramite)', [
                        'id_tramite' => $id_tramite
                    ]);
                    $response['success'] = true;
                    $response['data'] = $tramite[0] ?? null;
                    break;
                case 'reactivar_tramite':
                    $id_tramite = $params['id_tramite'] ?? null;
                    $motivo = $params['motivo'] ?? '';
                    if (!$id_tramite) {
                        throw new \Exception('id_tramite es requerido');
                    }
                    $result = DB::select('SELECT * FROM reactivar_tramite(:id_tramite, :motivo)', [
                        'id_tramite' => $id_tramite,
                        'motivo' => $motivo
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                default:
                    throw new \Exception('Acción no soportada: ' . $action);
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
