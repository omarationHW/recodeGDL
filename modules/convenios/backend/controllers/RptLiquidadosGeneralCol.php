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
                case 'RptLiquidadosGeneralCol':
                    $colonia = isset($params['colonia']) ? (int)$params['colonia'] : null;
                    $importe = isset($params['importe']) ? (float)$params['importe'] : null;
                    if ($colonia === null || $importe === null) {
                        throw new \Exception('Parámetros colonia e importe son requeridos.');
                    }
                    $result = DB::select('SELECT * FROM rpt_liquidados_general_col(:colonia, :importe)', [
                        'colonia' => $colonia,
                        'importe' => $importe
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'eRequest no soportado.';
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
