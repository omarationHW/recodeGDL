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
                case 'RptCuentaPublica.getReport':
                    // Expected params: axo (int), oficina (int)
                    $axo = isset($params['axo']) ? (int)$params['axo'] : null;
                    $oficina = isset($params['oficina']) ? (int)$params['oficina'] : null;
                    if ($axo === null || $oficina === null) {
                        throw new \Exception('Parámetros axo y oficina requeridos.');
                    }
                    $result = DB::select('SELECT * FROM rpt_cuenta_publica($1, $2)', [$axo, $oficina]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'eRequest no soportado: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
