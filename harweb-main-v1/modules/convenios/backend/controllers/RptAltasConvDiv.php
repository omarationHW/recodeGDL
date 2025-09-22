<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AltasConvDivController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getAltasConvDivReport':
                    $data = $this->getAltasConvDivReport($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'exportAltasConvDivExcel':
                    $file = $this->exportAltasConvDivExcel($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [ 'file_url' => $file ];
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Lógica para obtener el reporte de altas de convenios diversos
     * @param array $params
     * @return array
     */
    private function getAltasConvDivReport($params)
    {
        $rec = $params['rec'] ?? null;
        $fecha1 = $params['fecha1'] ?? null;
        $fecha2 = $params['fecha2'] ?? null;
        if (!$rec || !$fecha1 || !$fecha2) {
            throw new \Exception('Parámetros insuficientes');
        }
        // Llama al stored procedure de reporte
        $result = DB::select('SELECT * FROM sp_rpt_altas_conv_div(?, ?, ?)', [$rec, $fecha1, $fecha2]);
        return $result;
    }

    /**
     * Lógica para exportar el reporte a Excel (dummy, debe implementarse con paquete Excel)
     * @param array $params
     * @return string
     */
    private function exportAltasConvDivExcel($params)
    {
        // Aquí se implementaría la exportación real a Excel
        // Por ahora, solo retorna una URL dummy
        return url('/storage/altas_conv_div_report.xlsx');
    }
}
