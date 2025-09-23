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

        switch ($eRequest) {
            case 'getRecaudadorasReport':
                $opcion = isset($params['opcion']) ? intval($params['opcion']) : 1;
                $result = DB::select('SELECT * FROM sp_recaudadoras_report(?)', [$opcion]);
                return response()->json([
                    'eResponse' => 'getRecaudadorasReport',
                    'data' => $result
                ]);
            default:
                return response()->json([
                    'eResponse' => 'error',
                    'message' => 'Unknown eRequest: ' . $eRequest
                ], 400);
        }
    }
}
