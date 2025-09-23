<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AdeudosPrediosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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
                case 'getAdeudosPredios':
                    $data = DB::select('CALL sp_get_adeudos_predios(?, ?, ?)', [
                        $params['subtipo'],
                        $params['fecha_hasta'],
                        $params['estado']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'getAdeudosPrediosSaldoAnt':
                    $data = DB::select('CALL sp_get_adeudos_predios_saldo_ant(?, ?, ?, ?)', [
                        $params['subtipo'],
                        $params['fecha_desde'],
                        $params['fecha_hasta'],
                        $params['estado']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'getManzanas':
                    $data = DB::select('SELECT DISTINCT manzana FROM ta_17_con_reg_pred WHERE tipo = 14 AND subtipo = ?', [
                        $params['subtipo']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'getSubtipos':
                    $data = DB::select('SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = 14 ORDER BY desc_subtipo');
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
