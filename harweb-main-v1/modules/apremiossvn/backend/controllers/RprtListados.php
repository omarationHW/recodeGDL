<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

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
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getRprtListados':
                    $result = $this->getRprtListados($params);
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
     * Call the stored procedure for RprtListados
     * @param array $params
     * @return array
     */
    private function getRprtListados($params)
    {
        // Expected params: vrec, vmod, vfol1, vfol2, vcve, vvig, vfdsd, vfhst
        $vrec = $params['vrec'] ?? null;
        $vmod = $params['vmod'] ?? null;
        $vfol1 = $params['vfol1'] ?? null;
        $vfol2 = $params['vfol2'] ?? null;
        $vcve = $params['vcve'] ?? null;
        $vvig = $params['vvig'] ?? null;
        $vfdsd = $params['vfdsd'] ?? null;
        $vfhst = $params['vfhst'] ?? null;

        $result = DB::select('SELECT * FROM rprt_listados(:vrec, :vmod, :vfol1, :vfol2, :vcve, :vvig, :vfdsd, :vfhst)', [
            'vrec' => $vrec,
            'vmod' => $vmod,
            'vfol1' => $vfol1,
            'vfol2' => $vfol2,
            'vcve' => $vcve,
            'vvig' => $vvig,
            'vfdsd' => $vfdsd,
            'vfhst' => $vfhst
        ]);

        return $result;
    }
}
