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
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'login_seguridad':
                    // Call stored procedure for seguridad login
                    $user = $params['user'] ?? null;
                    $pass = $params['pass'] ?? null;
                    $result = DB::select('SELECT * FROM sp_login_seguridad(?, ?)', [$user, $pass]);
                    if (!empty($result) && $result[0]->success) {
                        $eResponse['success'] = true;
                        $eResponse['data'] = $result[0];
                    } else {
                        $eResponse['error'] = 'Invalid credentials';
                    }
                    break;
                case 'connect_estacion':
                    // Call stored procedure for estacion DB connection
                    $result = DB::select('SELECT * FROM sp_connect_estacion()');
                    if (!empty($result) && $result[0]->success) {
                        $eResponse['success'] = true;
                        $eResponse['data'] = $result[0];
                    } else {
                        $eResponse['error'] = 'Could not connect to estacion DB';
                    }
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['error'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
