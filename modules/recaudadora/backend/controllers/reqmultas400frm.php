<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests.
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
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'reqmultas400_by_acta':
                    // params: dep, axo, numacta, tipo
                    $result = DB::select('SELECT * FROM req_mul_400_by_acta(:dep, :axo, :numacta, :tipo)', [
                        'dep' => $params['dep'] ?? '',
                        'axo' => $params['axo'] ?? 0,
                        'numacta' => $params['numacta'] ?? 0,
                        'tipo' => $params['tipo'] ?? 0
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'reqmultas400_by_folio':
                    // params: axo, folio, tipo
                    $result = DB::select('SELECT * FROM req_mul_400_by_folio(:axo, :folio, :tipo)', [
                        'axo' => $params['axo'] ?? 0,
                        'folio' => $params['folio'] ?? 0,
                        'tipo' => $params['tipo'] ?? 0
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Invalid eRequest value.';
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
