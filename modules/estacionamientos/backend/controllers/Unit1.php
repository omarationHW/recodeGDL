<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

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
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'unit1_report':
                    // Validate required parameters
                    if (!isset($params['fechora'])) {
                        throw new \Exception('Missing parameter: fechora');
                    }
                    $fechora = $params['fechora'];
                    // Call stored procedure
                    $result = DB::select('SELECT * FROM report_unit1(:fechora)', [
                        'fechora' => $fechora
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    throw new \Exception('Unknown eRequest: ' . $eRequest);
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
