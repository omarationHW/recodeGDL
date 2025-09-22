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
                case 'rprt_listaxfec':
                    $result = $this->getRprtListaxFec($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }

    /**
     * Call stored procedure for RprtListaxFec report.
     * Params:
     *   vrec (int), vmod (int), vcve (int), vfec1 (date), vfec2 (date), vvig (string), veje (string)
     */
    private function getRprtListaxFec($params)
    {
        $vrec = $params['vrec'] ?? null;
        $vmod = $params['vmod'] ?? null;
        $vcve = $params['vcve'] ?? null;
        $vfec1 = $params['vfec1'] ?? null;
        $vfec2 = $params['vfec2'] ?? null;
        $vvig = $params['vvig'] ?? null;
        $veje = $params['veje'] ?? null;

        $sql = 'SELECT * FROM rprt_listaxfec(:vrec, :vmod, :vcve, :vfec1, :vfec2, :vvig, :veje)';
        $bindings = [
            'vrec' => $vrec,
            'vmod' => $vmod,
            'vcve' => $vcve,
            'vfec1' => $vfec1,
            'vfec2' => $vfec2,
            'vvig' => $vvig,
            'veje' => $veje
        ];
        $rows = DB::select($sql, $bindings);
        return $rows;
    }
}
