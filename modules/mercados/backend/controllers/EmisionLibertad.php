<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EmisionLibertadController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (eRequest/eResponse)
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
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT * FROM get_recaudadoras()');
                    $response['success'] = true;
                    break;
                case 'getMercadosByRecaudadora':
                    $oficina = $params['oficina'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM get_mercados_by_recaudadora(?)', [$oficina]);
                    $response['success'] = true;
                    break;
                case 'generarEmisionLibertad':
                    $oficina = $params['oficina'];
                    $mercados = $params['mercados']; // array de IDs
                    $axo = $params['axo'];
                    $periodo = $params['periodo'];
                    $usuario_id = $params['usuario_id'];
                    $result = DB::select('SELECT * FROM generar_emision_libertad(?, ?, ?, ?, ?)', [
                        $oficina,
                        json_encode($mercados),
                        $axo,
                        $periodo,
                        $usuario_id
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'exportarEmisionLibertad':
                    $oficina = $params['oficina'];
                    $mercados = $params['mercados'];
                    $axo = $params['axo'];
                    $periodo = $params['periodo'];
                    $usuario_id = $params['usuario_id'];
                    $file = DB::select('SELECT * FROM exportar_emision_libertad(?, ?, ?, ?, ?)', [
                        $oficina,
                        json_encode($mercados),
                        $axo,
                        $periodo,
                        $usuario_id
                    ]);
                    $response['data'] = $file;
                    $response['success'] = true;
                    break;
                case 'getEmisionLibertadDetalle':
                    $oficina = $params['oficina'];
                    $mercados = $params['mercados'];
                    $axo = $params['axo'];
                    $periodo = $params['periodo'];
                    $response['data'] = DB::select('SELECT * FROM get_emision_libertad_detalle(?, ?, ?, ?)', [
                        $oficina,
                        json_encode($mercados),
                        $axo,
                        $periodo
                    ]);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error('EmisionLibertadController error: ' . $e->getMessage());
        }

        return response()->json($response);
    }
}
