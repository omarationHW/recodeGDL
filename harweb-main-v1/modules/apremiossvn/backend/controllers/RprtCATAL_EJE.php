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
                case 'RprtCATAL_EJE.list':
                    $id_rec = isset($params['id_rec']) ? $params['id_rec'] : null;
                    $vigencia = isset($params['vigencia']) ? $params['vigencia'] : null;
                    $result = DB::select('SELECT * FROM rpt_catal_eje(:id_rec, :vigencia)', [
                        'id_rec' => $id_rec,
                        'vigencia' => $vigencia
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RprtCATAL_EJE.detail':
                    $id_ejecutor = isset($params['id_ejecutor']) ? $params['id_ejecutor'] : null;
                    $result = DB::select('SELECT * FROM ta_15_ejecutores WHERE id_ejecutor = :id_ejecutor', [
                        'id_ejecutor' => $id_ejecutor
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
