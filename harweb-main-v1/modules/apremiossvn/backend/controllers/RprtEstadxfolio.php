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
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'getEstadxFolioReport':
                    $result = $this->getEstadxFolioReport($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRecaudadoraZona':
                    $result = $this->getRecaudadoraZona($params);
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
     * Call stored procedure for EstadxFolio report
     */
    private function getEstadxFolioReport($params)
    {
        $modu = isset($params['modu']) ? (int)$params['modu'] : null;
        $rec = isset($params['rec']) ? (int)$params['rec'] : null;
        $fol1 = isset($params['fol1']) ? (int)$params['fol1'] : null;
        $fol2 = isset($params['fol2']) ? (int)$params['fol2'] : null;
        if (is_null($modu) || is_null($rec) || is_null($fol1) || is_null($fol2)) {
            throw new \Exception('Missing parameters for EstadxFolio report');
        }
        $result = DB::select('SELECT * FROM rpt_estadxfolio(:modu, :rec, :fol1, :fol2)', [
            'modu' => $modu,
            'rec' => $rec,
            'fol1' => $fol1,
            'fol2' => $fol2
        ]);
        return $result;
    }

    /**
     * Call stored procedure for recaudadora/zona info
     */
    private function getRecaudadoraZona($params)
    {
        $reca = isset($params['reca']) ? (int)$params['reca'] : null;
        if (is_null($reca)) {
            throw new \Exception('Missing parameter reca for recaudadora/zona');
        }
        $result = DB::select('SELECT * FROM rpt_recaudadora_zona(:reca)', [
            'reca' => $reca
        ]);
        return $result;
    }
}
