<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

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
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];

        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getContratosDet':
                    // Call stored procedure with params
                    $vigencia = $params['vigencia'] ?? 'T';
                    $ofna = $params['ofna'] ?? 0;
                    $opcion = $params['opcion'] ?? 1;
                    $num_emp = $params['num_emp'] ?? null;
                    $result = DB::select('SELECT * FROM rpt_contratos_det(:vigencia, :ofna, :opcion, :num_emp)', [
                        'vigencia' => $vigencia,
                        'ofna' => $ofna,
                        'opcion' => $opcion,
                        'num_emp' => $num_emp
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getContratosDetSummary':
                    $vigencia = $params['vigencia'] ?? 'T';
                    $ofna = $params['ofna'] ?? 0;
                    $opcion = $params['opcion'] ?? 1;
                    $num_emp = $params['num_emp'] ?? null;
                    $summary = DB::select('SELECT * FROM rpt_contratos_det_summary(:vigencia, :ofna, :opcion, :num_emp)', [
                        'vigencia' => $vigencia,
                        'ofna' => $ofna,
                        'opcion' => $opcion,
                        'num_emp' => $num_emp
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $summary;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
