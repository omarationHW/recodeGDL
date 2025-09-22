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
                case 'test_connection':
                    // Call stored procedure to test connection
                    $user = $params['user'] ?? null;
                    $password = $params['password'] ?? null;
                    if (!$user || !$password) {
                        $eResponse['message'] = 'Missing user or password.';
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_test_connection(?, ?)', [$user, $password]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['data'] = $result[0];
                    $eResponse['message'] = $result[0]->message;
                    break;
                case 'get_databases':
                    // List available databases
                    $result = DB::select('SELECT * FROM sp_get_databases()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'close_connection':
                    // Simulate closing connection (stateless API)
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Connection closed (stateless API).';
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest.';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = 'Internal server error.';
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
