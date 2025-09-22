<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'RptReqPbaAseo:getReport':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('CALL rptreq_pba_aseo_get_report(?, ?, ?)', [
                        $params['id_rec'],
                        $params['tipo_aseo'] ?? 'todos',
                        $params['fecha_corte']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptReqPbaAseo:getGastos':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('CALL rptreq_pba_aseo_get_gastos(?, ?)', [
                        $params['axo'],
                        $params['mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptReqPbaAseo:getRecarg':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('CALL rptreq_pba_aseo_get_recarg(?, ?, ?)', [
                        $params['axo_inicio'],
                        $params['mes_inicio'],
                        $params['axo_fin']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptReqPbaAseo:getLimite':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('CALL rptreq_pba_aseo_get_limite(?)', [
                        $params['mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptReqPbaAseo:getRecaudadora':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('CALL rptreq_pba_aseo_get_recaudadora(?)', [
                        $params['id_rec']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
