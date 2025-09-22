<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones vía eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eParams = $request->input('eParams', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RptDesgloceAdeporImporte':
                    $year = isset($eParams['year']) ? (int)$eParams['year'] : null;
                    $period = isset($eParams['period']) ? (int)$eParams['period'] : null;
                    $amount = isset($eParams['amount']) ? (float)$eParams['amount'] : null;
                    $option = isset($eParams['option']) ? (int)$eParams['option'] : 0;

                    if ($year === null || $period === null || $amount === null) {
                        $eResponse['message'] = 'Parámetros insuficientes';
                        break;
                    }

                    $result = DB::select('SELECT * FROM spd_11_ade_axo(:parm_axo, :parm_mes, :parm_cuota)', [
                        'parm_axo' => $year,
                        'parm_mes' => $period,
                        'parm_cuota' => $amount
                    ]);

                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;

                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
