<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
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
                case 'getMetrometersByAxoFolio':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    if (is_null($axo) || is_null($folio)) {
                        throw new \Exception('Parámetros axo y folio requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_get_metrometers_by_axo_folio(?, ?)', [$axo, $folio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMetrometersPhoto':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $photo_number = $params['photo_number'] ?? 1;
                    if (is_null($axo) || is_null($folio)) {
                        throw new \Exception('Parámetros axo y folio requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_get_metrometers_photo(?, ?, ?)', [$axo, $folio, $photo_number]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMetrometersMapUrl':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    if (is_null($axo) || is_null($folio)) {
                        throw new \Exception('Parámetros axo y folio requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_get_metrometers_map_url(?, ?)', [$axo, $folio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
                    break;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
