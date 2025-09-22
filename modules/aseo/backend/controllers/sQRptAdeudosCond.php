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
                case 'getAdeudosCondonados':
                    $control_contrato = $params['control_contrato'] ?? null;
                    $opcion = $params['opcion'] ?? 1;
                    if (!$control_contrato) {
                        throw new \Exception('control_contrato es requerido');
                    }
                    $result = DB::select('SELECT * FROM rpt_adeudos_condonados(:control_contrato, :opcion)', [
                        'control_contrato' => $control_contrato,
                        'opcion' => $opcion
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
