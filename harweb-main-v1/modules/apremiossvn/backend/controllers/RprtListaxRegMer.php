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
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getRprtListaxRegMer':
                    $result = DB::select('SELECT * FROM rpt_listax_reg_mer(:vigencia, :clave_practicado, :num_mercado, :oficina)', [
                        'vigencia' => $params['vigencia'] ?? 'todas',
                        'clave_practicado' => $params['clave_practicado'] ?? 'todas',
                        'num_mercado' => $params['num_mercado'] ?? 0,
                        'oficina' => $params['oficina'] ?? 0
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRecaudadoraZona':
                    $result = DB::select('SELECT * FROM get_recaudadora_zona(:oficina)', [
                        'oficina' => $params['oficina'] ?? 0
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
