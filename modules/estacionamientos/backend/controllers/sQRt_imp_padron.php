<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute endpoint.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);

        switch ($eRequest) {
            case 'get_padron_report':
                return $this->getPadronReport($params);
            default:
                return response()->json([
                    'eResponse' => 'error',
                    'message' => 'Unknown eRequest',
                ], 400);
        }
    }

    /**
     * Fetch padron vehicular report between two IDs.
     *
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    protected function getPadronReport($params)
    {
        $id1 = isset($params['id1']) ? (int)$params['id1'] : null;
        $id2 = isset($params['id2']) ? (int)$params['id2'] : null;

        if ($id1 === null || $id2 === null) {
            return response()->json([
                'eResponse' => 'error',
                'message' => 'Missing parameters id1 or id2',
            ], 422);
        }

        try {
            $results = DB::select('SELECT * FROM sp_get_padron_report(?, ?)', [$id1, $id2]);
            return response()->json([
                'eResponse' => 'success',
                'data' => $results,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
