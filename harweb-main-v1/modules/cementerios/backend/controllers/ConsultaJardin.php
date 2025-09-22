<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Routing\Controller as BaseController;

class ExecuteController extends BaseController
{
    /**
     * Endpoint único para ejecutar acciones eRequest/eResponse
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'consulta_jardin_by_rcm':
                    $result = DB::select('SELECT * FROM consulta_jardin_by_rcm(:vclase, :vsec, :vlinea)', [
                        'vclase' => $params['vclase'],
                        'vsec' => $params['vsec'],
                        'vlinea' => $params['vlinea'],
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'consulta_jardin_by_nombre':
                    $result = DB::select('SELECT * FROM consulta_jardin_by_nombre(:nombre)', [
                        'nombre' => $params['nombre'],
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'consulta_jardin_by_partida':
                    $result = DB::select('SELECT * FROM consulta_jardin_by_partida(:ppago)', [
                        'ppago' => $params['ppago'],
                    ]);
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
