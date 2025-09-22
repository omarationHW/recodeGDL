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

        switch ($eRequest) {
            case 'getPagosPorContrato':
                return $this->getPagosPorContrato($params);
            default:
                return response()->json([
                    'eResponse' => 'error',
                    'message' => 'Unknown eRequest',
                ], 400);
        }
    }

    /**
     * Report: Pagos por Contrato
     * Calls stored procedure: rpt_pagos_por_contrato
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function getPagosPorContrato($params)
    {
        $control = isset($params['control']) ? (int)$params['control'] : null;
        $contrato = isset($params['contrato']) ? (int)$params['contrato'] : null;
        $ctrol_aseo = isset($params['ctrol_aseo']) ? (int)$params['ctrol_aseo'] : null;

        if (is_null($control) || is_null($contrato) || is_null($ctrol_aseo)) {
            return response()->json([
                'eResponse' => 'error',
                'message' => 'Missing required parameters: control, contrato, ctrol_aseo',
            ], 422);
        }

        // Call the stored procedure
        $results = DB::select('SELECT * FROM rpt_pagos_por_contrato(?, ?, ?)', [
            $control, $contrato, $ctrol_aseo
        ]);

        // Calculate summary
        $summary = [
            'total_registros' => 0,
            'total_importe' => 0.0,
            'cuota_normal' => [ 'count' => 0, 'importe' => 0.0 ],
            'excedente' => [ 'count' => 0, 'importe' => 0.0 ],
            'contenedores' => [ 'count' => 0, 'importe' => 0.0 ],
        ];

        foreach ($results as $row) {
            $summary['total_registros']++;
            $summary['total_importe'] += (float)$row->importe;
            switch (strtoupper(trim($row->descripcion))) {
                case 'CUOTA NORMAL':
                    $summary['cuota_normal']['count']++;
                    $summary['cuota_normal']['importe'] += (float)$row->importe;
                    break;
                case 'EXCEDENTE':
                    $summary['excedente']['count']++;
                    $summary['excedente']['importe'] += (float)$row->importe;
                    break;
                case 'CONTENEDORES':
                    $summary['contenedores']['count']++;
                    $summary['contenedores']['importe'] += (float)$row->importe;
                    break;
            }
        }

        // Aseo label
        $aseo_label = '';
        if ($ctrol_aseo == 4) $aseo_label = 'HOSPITALARIO';
        if ($ctrol_aseo == 8) $aseo_label = 'ORDINARIO';
        if ($ctrol_aseo == 9) $aseo_label = 'ZONA CENTRO';

        return response()->json([
            'eResponse' => 'success',
            'data' => $results,
            'summary' => $summary,
            'contrato' => $contrato,
            'aseo_label' => $aseo_label
        ]);
    }
}
