<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
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
                case 'RptAdeudosContratos':
                    $colonia = $params['colonia'] ?? null;
                    $calle = $params['calle'] ?? null;
                    $rep = $params['rep'] ?? 1;
                    if (is_null($colonia) || is_null($calle)) {
                        throw new \Exception('Parámetros colonia y calle son requeridos');
                    }
                    $result = DB::select('SELECT * FROM rpt_adeudos_contratos(:colonia, :calle, :rep)', [
                        'colonia' => $colonia,
                        'calle' => $calle,
                        'rep' => $rep
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
