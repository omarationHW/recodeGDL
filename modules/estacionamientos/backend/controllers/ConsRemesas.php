<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests.
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'getRemesas':
                    // params: tipo (A, B, C, D)
                    $tipo = $params['tipo'] ?? 'A';
                    $result = DB::select('SELECT * FROM sp_get_remesas(?)', [$tipo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRemesaDetalle':
                    // params: tipo (A, B, C, D), num_remesa (int)
                    $tipo = $params['tipo'] ?? 'A';
                    $num_remesa = $params['num_remesa'] ?? null;
                    if ($num_remesa === null) {
                        throw new \Exception('num_remesa is required');
                    }
                    if ($tipo === 'A') {
                        $remesa = 'dti_est_r' . $num_remesa;
                        $result = DB::select('SELECT * FROM sp_get_remesa_detalle_edo(?)', [$remesa]);
                    } else {
                        $remesa = 'ayt_gdl_r' . $num_remesa;
                        $result = DB::select('SELECT * FROM sp_get_remesa_detalle_mpio(?)', [$remesa]);
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
