<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for repavance (avance de recaudación de multas)
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'repavance_generate_report':
                    $result = $this->generateReport($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Generate the report for avance de recaudación de multas
     * @param array $params
     * @return array
     */
    private function generateReport($params)
    {
        // Params: mes (0-11), anio, recaudadora_id, tipo (M/F)
        $mes = $params['mes'] ?? null; // 0-based index
        $anio = $params['anio'] ?? null;
        $recaudadora_id = $params['recaudadora_id'] ?? null;
        $tipo = $params['tipo'] ?? 'M'; // 'M' municipal, 'F' federal

        if ($mes === null || !$anio || !$recaudadora_id) {
            throw new \Exception('Parámetros insuficientes');
        }

        // Calcular fechas mínimo y máximo
        $meses = [
            [1, 31], [2, 28], [3, 31], [4, 30], [5, 31], [6, 30],
            [7, 31], [8, 31], [9, 30], [10, 31], [11, 30], [12, 31]
        ];
        $mes_num = $meses[$mes][0];
        $dia_max = $meses[$mes][1];
        // Ajuste para año bisiesto en febrero
        if ($mes == 1 && ($anio % 4 == 0)) {
            $dia_max = 29;
        }
        $minimo = sprintf('%04d-%02d-01', $anio, $mes_num);
        $maximo = sprintf('%04d-%02d-%02d', $anio, $mes_num, $dia_max);

        // Ejecutar el procedimiento almacenado principal
        $sp_result = DB::select('SELECT * FROM repavance_generate_report(?, ?, ?, ?, ?)', [
            $recaudadora_id, $minimo, $maximo, $tipo, $anio
        ]);

        // El SP retorna un JSON con los datos del reporte
        $data = $sp_result[0]->report_data ?? null;
        if ($data) {
            $data = json_decode($data, true);
        }

        return [
            'params' => [
                'mes' => $mes,
                'anio' => $anio,
                'recaudadora_id' => $recaudadora_id,
                'tipo' => $tipo,
                'minimo' => $minimo,
                'maximo' => $maximo
            ],
            'report' => $data
        ];
    }
}
