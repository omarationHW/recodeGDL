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
    public function handle(Request $request)
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
                case 'sqrp_esta01_report':
                    // Params: axo_from, axo_to (optional filtering by year)
                    $axo_from = isset($params['axo_from']) ? $params['axo_from'] : null;
                    $axo_to = isset($params['axo_to']) ? $params['axo_to'] : null;
                    $result = DB::select('SELECT * FROM sqrp_esta01_report(:axo_from, :axo_to)', [
                        'axo_from' => $axo_from,
                        'axo_to' => $axo_to
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

        return response()->json(['eResponse' => $eResponse]);
    }
}
