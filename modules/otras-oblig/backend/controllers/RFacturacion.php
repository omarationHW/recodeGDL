<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del sistema (eRequest/eResponse)
     *
     * @param  \Illuminate\Http\Request  $request
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
                case 'getRFacturacionReport':
                    // Parámetros esperados: adeudo_status, adeudo_recargo, year, month, periodo_actual
                    $adeudo_status = $eRequest['params']['adeudo_status'] ?? 'A';
                    $adeudo_recargo = $eRequest['params']['adeudo_recargo'] ?? 'N';
                    $year = (int)($eRequest['params']['year'] ?? date('Y'));
                    $month = (int)($eRequest['params']['month'] ?? date('m'));
                    $periodo_actual = (bool)($eRequest['params']['periodo_actual'] ?? true);

                    // Llama al stored procedure de PostgreSQL
                    $result = DB::select('SELECT * FROM con34_gfact_02(?, ?, ?, ?)', [
                        $adeudo_status,
                        $adeudo_recargo,
                        $year,
                        $month
                    ]);

                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Reporte generado correctamente.';
                    break;

                default:
                    $eResponse['message'] = 'Acción no soportada: ' . $eRequest['action'];
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = 'Error: ' . $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
