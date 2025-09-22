<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'RptFact_Merc.getReport':
                    // Parámetros esperados: rec, fol1, fol2
                    $rec = $eRequest['params']['rec'] ?? null;
                    $fol1 = $eRequest['params']['fol1'] ?? null;
                    $fol2 = $eRequest['params']['fol2'] ?? null;
                    if ($rec === null || $fol1 === null || $fol2 === null) {
                        throw new \Exception('Parámetros insuficientes');
                    }
                    $result = DB::select('SELECT * FROM rptfact_merc_get_report(?, ?, ?)', [$rec, $fol1, $fol2]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                // Aquí se pueden agregar más acciones
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
