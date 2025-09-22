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
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);

        switch ($eRequest) {
            case 'sqrp_publicos_report':
                return $this->sqrpPublicosReport($params);
            default:
                return response()->json([
                    'eResponse' => [
                        'status' => 'error',
                        'message' => 'Unknown eRequest',
                        'data' => null
                    ]
                ], 400);
        }
    }

    /**
     * sqrp_publicos_report: Get report of estacionamientos públicos
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function sqrpPublicosReport($params)
    {
        $opc = isset($params['opc']) ? (int)$params['opc'] : 1;
        $orderBy = 'a.cve_numero';
        $caption = 'Relación de Estacionamientos Públicos clasificado por : Número';
        switch ($opc) {
            case 2:
                $orderBy = 'a.nombre';
                $caption = 'Relación de Estacionamientos Públicos clasificado por : Nombre';
                break;
            case 3:
                $orderBy = 'a.calle';
                $caption = 'Relación de Estacionamientos Públicos clasificado por : Calle';
                break;
            case 4:
                $orderBy = 'a.cve_sector, a.calle';
                $caption = 'Relación de Estacionamientos Públicos clasificado por : Sector y Calle';
                break;
            case 5:
                $orderBy = 'a.zona, a.subzona';
                $caption = 'Relación de Estacionamientos Públicos clasificado por : Zona y Sub-Zona';
                break;
        }

        // Call stored procedure
        $results = DB::select('SELECT * FROM sqrp_publicos_report(:order_by)', [
            'order_by' => $orderBy
        ]);

        return response()->json([
            'eResponse' => [
                'status' => 'success',
                'message' => $caption,
                'data' => $results
            ]
        ]);
    }
}
