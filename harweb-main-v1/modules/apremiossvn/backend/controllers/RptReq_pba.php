<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones eRequest/eResponse
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
                case 'RptReqPba_getReportData':
                    $data = DB::select('SELECT * FROM rptreq_pba_get_report_data(?, ?, ?, ?, ?)', [
                        $params['vmerc1'],
                        $params['vmerc2'],
                        $params['vlocal1'],
                        $params['vlocal2'],
                        $params['vsecc']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'RptReqPba_getRecargos':
                    $data = DB::select('SELECT * FROM rptreq_pba_get_recargos(?, ?, ?, ?, ?)', [
                        $params['axo'],
                        $params['periodo'],
                        $params['vaxo'],
                        $params['vmes'],
                        $params['vdia']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'RptReqPba_getGastos':
                    $data = DB::select('SELECT * FROM rptreq_pba_get_gastos(?, ?)', [
                        $params['axo'],
                        $params['mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'RptReqPba_getRecaudadora':
                    $data = DB::select('SELECT * FROM rptreq_pba_get_recaudadora(?)', [
                        $params['reca']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
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
