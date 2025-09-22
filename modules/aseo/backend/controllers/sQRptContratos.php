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

        switch ($eRequest) {
            case 'RptContratos':
                return $this->rptContratos($params);
            default:
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'eRequest not recognized',
                        'data' => null
                    ]
                ], 400);
        }
    }

    /**
     * Reporte de Contratos (equivalente a impr_todo)
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function rptContratos($params)
    {
        // Parámetros esperados
        $seleccion = isset($params['seleccion']) ? (int)$params['seleccion'] : 1;
        $Ofna = isset($params['Ofna']) ? (int)$params['Ofna'] : 0;
        $Rep = isset($params['Rep']) ? (int)$params['Rep'] : 0;
        $opcion = isset($params['opcion']) ? (int)$params['opcion'] : 1;
        $Num_emp = isset($params['Num_emp']) ? (int)$params['Num_emp'] : 0;
        $Ctrol_Aseo = isset($params['Ctrol_Aseo']) ? (int)$params['Ctrol_Aseo'] : 0;
        $Vigencia = isset($params['Vigencia']) ? $params['Vigencia'] : 'T';

        // Llamada al stored procedure
        $results = DB::select('SELECT * FROM rpt_contratos(:seleccion, :ofna, :rep, :opcion, :num_emp, :ctrol_aseo, :vigencia)', [
            'seleccion' => $seleccion,
            'ofna' => $Ofna,
            'rep' => $Rep,
            'opcion' => $opcion,
            'num_emp' => $Num_emp,
            'ctrol_aseo' => $Ctrol_Aseo,
            'vigencia' => $Vigencia
        ]);

        // Contar vigentes y cancelados
        $vigentes = 0;
        $cancelados = 0;
        foreach ($results as $row) {
            if ($row->status_vigencia === 'V') {
                $vigentes++;
            } elseif ($row->status_vigencia === 'C') {
                $cancelados++;
            }
        }

        return response()->json([
            'eResponse' => [
                'success' => true,
                'message' => 'Reporte generado',
                'data' => [
                    'contratos' => $results,
                    'totales' => [
                        'total' => count($results),
                        'vigentes' => $vigentes,
                        'cancelados' => $cancelados
                    ]
                ]
            ]
        ]);
    }
}
