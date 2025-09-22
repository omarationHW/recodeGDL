<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for sfrm_consultapublicos
     * Endpoint: /api/execute
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
                case 'getPublicParkingList':
                    $data = DB::select('SELECT * FROM sp_get_public_parking_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getPublicParkingDebts':
                    $pubid = $params['pubid'] ?? null;
                    if (!$pubid) throw new \Exception('pubid is required');
                    $data = DB::select('SELECT * FROM sp_get_public_parking_debts(?)', [$pubid]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getPublicParkingFines':
                    $numlicencia = $params['numlicencia'] ?? null;
                    if (!$numlicencia) throw new \Exception('numlicencia is required');
                    $data = DB::select('SELECT * FROM sp_get_public_parking_fines(?)', [$numlicencia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getLicenseGeneral':
                    $numlicencia = $params['numlicencia'] ?? null;
                    if (!$numlicencia) throw new \Exception('numlicencia is required');
                    $data = DB::select('SELECT * FROM sp_get_license_general(?, 0, 4)', [$numlicencia]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getLicenseTotals':
                    $id_licencia = $params['id_licencia'] ?? null;
                    $tipo_l = $params['tipo_l'] ?? 'L';
                    $redon = $params['redon'] ?? 'N';
                    if (!$id_licencia) throw new \Exception('id_licencia is required');
                    $data = DB::select('SELECT * FROM sp_get_license_totals(?, ?, ?)', [$id_licencia, $tipo_l, $redon]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
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
