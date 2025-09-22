<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                case 'RptServicios.getAll':
                    // Call stored procedure to get all servicios
                    $result = DB::select('SELECT * FROM rptservicios_get_all()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptServicios.count':
                    // Call stored procedure to count servicios
                    $result = DB::select('SELECT rptservicios_count() as total');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->total;
                    break;
                default:
                    $eResponse['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
