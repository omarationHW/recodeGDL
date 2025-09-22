<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'get_calcomania_report':
                    $fecha1 = $params['fecha1'] ?? null;
                    $fecha2 = $params['fecha2'] ?? null;
                    $result = DB::select('SELECT * FROM sp_report_calcomanias(:fecha1, :fecha2)', [
                        'fecha1' => $fecha1,
                        'fecha2' => $fecha2
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_folios_report':
                    $fechora = $params['fechora'] ?? null;
                    $result = DB::select('SELECT * FROM sp_report_folios(:fechora)', [
                        'fechora' => $fechora
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_inspectors':
                    $result = DB::select('SELECT * FROM sp_catalog_inspectors()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
