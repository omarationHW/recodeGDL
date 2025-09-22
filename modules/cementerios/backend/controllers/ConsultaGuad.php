<?php

namespace App\Http\Controllers\ConsultaGuad;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ConsultaGuadController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'consulta_por_rcm':
                    $data = DB::select('SELECT * FROM consulta_guad_por_rcm(?, ?, ?)', [
                        $params['clase'],
                        $params['seccion'],
                        $params['linea']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'consulta_por_nombre':
                    $data = DB::select('SELECT * FROM consulta_guad_por_nombre(?)', [
                        $params['nombre']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'consulta_por_partida':
                    $data = DB::select('SELECT * FROM consulta_guad_por_partida(?)', [
                        $params['partida']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data;
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
