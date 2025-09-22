<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests.
     * Endpoint: /api/execute
     */
    public function handle(Request $request)
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
                case 'RptListado_Aseo':
                    $eResponse = $this->getRptListadoAseo($params);
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }

    /**
     * Get Listado de Adeudos para Requerimiento de Pago y Embargo, Derechos de Aseo Contratado
     * Params:
     *   vtipo: string (tipo de aseo, 'todos' para todos)
     *   xnum1: int (contrato inicial)
     *   xnum2: int (contrato final)
     *   vrec: int (id_rec)
     *   fecha_corte: date (fecha de corte, formato YYYY-MM-DD)
     */
    private function getRptListadoAseo($params)
    {
        $vtipo = $params['vtipo'] ?? 'todos';
        $xnum1 = $params['xnum1'] ?? 0;
        $xnum2 = $params['xnum2'] ?? 0;
        $vrec = $params['vrec'] ?? 1;
        $fecha_corte = $params['fecha_corte'] ?? date('Y-m-d');

        // Lógica para obtener mes y día de corte
        $fecha = new \DateTime($fecha_corte);
        $vaxo = (int)$fecha->format('Y');
        $vmes = (int)$fecha->format('m');
        $vdia = (int)$fecha->format('d');

        // Obtener límite de día para el mes
        $limite = DB::selectOne('SELECT dia FROM ta_16_dia_limite WHERE mes = ?', [$vmes]);
        $vxmes = $vmes;
        if ($limite) {
            if ($limite->dia <= $vdia) {
                $vxmes = $vmes - 1;
            }
        }
        if ($vxmes < 10) {
            $vxmes = '0' . $vxmes;
        }

        // Llamar SP principal
        $result = DB::select('SELECT * FROM rpt_listado_aseo(?, ?, ?, ?, ?, ?)', [
            $vtipo,
            $xnum1,
            $xnum2,
            $vrec,
            $vaxo,
            $vxmes
        ]);

        // Totales generales
        $total_importe = 0;
        $total_recargos = 0;
        $total_multas = 0;
        $total_gastos = 0;
        $total_general = 0;
        foreach ($result as $row) {
            $total_importe += $row->importe;
            $total_recargos += $row->recargos;
            $total_multas += $row->importe * 0.5;
            $total_gastos += $row->total_gasto;
            $total_general += $row->importe + $row->recargos + $row->total_gasto + ($row->importe * 0.5);
        }

        return [
            'success' => true,
            'data' => [
                'rows' => $result,
                'totals' => [
                    'total_importe' => $total_importe,
                    'total_recargos' => $total_recargos,
                    'total_multas' => $total_multas,
                    'total_gastos' => $total_gastos,
                    'total_general' => $total_general
                ]
            ],
            'message' => ''
        ];
    }
}
