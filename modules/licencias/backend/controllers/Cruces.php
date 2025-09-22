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
                case 'cruces_search_calle1':
                    $search = isset($params['search']) ? $params['search'] : '';
                    $result = DB::select('SELECT * FROM sp_cruces_search_calle1(?)', [$search]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'cruces_search_calle2':
                    $search = isset($params['search']) ? $params['search'] : '';
                    $result = DB::select('SELECT * FROM sp_cruces_search_calle2(?)', [$search]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'cruces_localiza_calle':
                    $cvecalle1 = isset($params['cvecalle1']) ? $params['cvecalle1'] : 0;
                    $cvecalle2 = isset($params['cvecalle2']) ? $params['cvecalle2'] : 0;
                    $result = DB::select('SELECT * FROM sp_cruces_localiza_calle(?, ?)', [$cvecalle1, $cvecalle2]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            Log::error('ExecuteController error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
