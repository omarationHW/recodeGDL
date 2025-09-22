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
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($eRequest) {
            case 'RptReq_Aseo.getReport':
                return $this->getRptReqAseo($params, $userId);
            default:
                return response()->json([
                    'eResponse' => 'error',
                    'message' => 'Unknown eRequest',
                ], 400);
        }
    }

    /**
     * Get RptReq_Aseo report data
     * @param array $params
     * @param int|null $userId
     * @return \Illuminate\Http\JsonResponse
     */
    protected function getRptReqAseo($params, $userId)
    {
        // Validate params
        $folio1 = isset($params['folio1']) ? (int)$params['folio1'] : null;
        $folio2 = isset($params['folio2']) ? (int)$params['folio2'] : null;
        $ofna = isset($params['ofna']) ? (int)$params['ofna'] : null;
        if (!$folio1 || !$folio2 || !$ofna) {
            return response()->json([
                'eResponse' => 'error',
                'message' => 'Missing parameters: folio1, folio2, ofna',
            ], 422);
        }

        // Call stored procedure
        $result = DB::select('SELECT * FROM rptreq_aseo_report(?, ?, ?)', [$ofna, $folio1, $folio2]);
        $recaudadora = DB::select('SELECT * FROM rptreq_aseo_recaudadora(?)', [$ofna]);

        // Compose response
        return response()->json([
            'eResponse' => 'RptReq_Aseo.getReport',
            'data' => [
                'adeudos' => $result,
                'recaudadora' => $recaudadora,
            ],
        ]);
    }
}
