<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for BloquearTramitefrm.
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getTramite':
                    $tramite = DB::select('SELECT * FROM get_tramite(:id_tramite)', [
                        'id_tramite' => $params['id_tramite']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $tramite;
                    break;
                case 'getBloqueos':
                    $bloqueos = DB::select('SELECT * FROM get_bloqueos(:id_tramite)', [
                        'id_tramite' => $params['id_tramite']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $bloqueos;
                    break;
                case 'getGiroDescripcion':
                    $giro = DB::select('SELECT * FROM get_giro_descripcion(:id_giro)', [
                        'id_giro' => $params['id_giro']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $giro;
                    break;
                case 'bloquearTramite':
                    $result = DB::select('SELECT * FROM bloquear_tramite(:id_tramite, :observa, :capturista)', [
                        'id_tramite' => $params['id_tramite'],
                        'observa' => $params['observa'],
                        'capturista' => $params['capturista']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'desbloquearTramite':
                    $result = DB::select('SELECT * FROM desbloquear_tramite(:id_tramite, :observa, :capturista)', [
                        'id_tramite' => $params['id_tramite'],
                        'observa' => $params['observa'],
                        'capturista' => $params['capturista']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}
