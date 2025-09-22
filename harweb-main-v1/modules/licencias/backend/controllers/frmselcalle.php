<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

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
        $eParams = $request->input('eParams', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_calles':
                    // eParams: { filter: 'string' }
                    $filter = isset($eParams['filter']) ? $eParams['filter'] : '';
                    $result = DB::select('SELECT * FROM sp_get_calles(?)', [$filter]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'get_calle_by_ids':
                    // eParams: { ids: [int, ...] }
                    $ids = isset($eParams['ids']) ? $eParams['ids'] : [];
                    if (!is_array($ids) || empty($ids)) {
                        $eResponse['message'] = 'No calle IDs provided.';
                        break;
                    }
                    // Convert array to comma-separated string
                    $ids_str = implode(',', array_map('intval', $ids));
                    $result = DB::select('SELECT * FROM sp_get_calle_by_ids(?)', [$ids_str]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
