<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests using eRequest/eResponse pattern.
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
                case 'getConsHis':
                    $control = $params['control'] ?? null;
                    if (!$control) {
                        throw new \Exception('Parameter control is required');
                    }
                    $result = DB::select('SELECT * FROM sp_get_cons_his(?)', [$control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getConsHisDetails':
                    $control_otr = $params['control_otr'] ?? null;
                    if (!$control_otr) {
                        throw new \Exception('Parameter control_otr is required');
                    }
                    $result = DB::select('SELECT * FROM sp_get_cons_his_details(?)', [$control_otr]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getAseoReference':
                    $contrato = $params['contrato'] ?? null;
                    if (!$contrato) {
                        throw new \Exception('Parameter contrato is required');
                    }
                    $result = DB::select('SELECT * FROM sp_get_aseo_reference(?)', [$contrato]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMercadoReference':
                    $local = $params['local'] ?? null;
                    if (!$local) {
                        throw new \Exception('Parameter local is required');
                    }
                    $result = DB::select('SELECT * FROM sp_get_mercado_reference(?)', [$local]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    throw new \Exception('Unknown eRequest: ' . $eRequest);
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
