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
        $eParams = $request->input('eParams', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'RptFacturaEnergia.getReport':
                    $oficina = $eParams['oficina'] ?? null;
                    $axo = $eParams['axo'] ?? null;
                    $periodo = $eParams['periodo'] ?? null;
                    $mercado = $eParams['mercado'] ?? null;
                    if (is_null($oficina) || is_null($axo) || is_null($periodo) || is_null($mercado)) {
                        throw new \Exception('Parámetros requeridos: oficina, axo, periodo, mercado');
                    }
                    $result = DB::select('SELECT * FROM rpt_factura_energia(:oficina, :axo, :periodo, :mercado)', [
                        'oficina' => $oficina,
                        'axo' => $axo,
                        'periodo' => $periodo,
                        'mercado' => $mercado
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptFacturaEnergia.getPeriodLabel':
                    $periodo = $eParams['periodo'] ?? null;
                    $axo = $eParams['axo'] ?? null;
                    if (is_null($periodo) || is_null($axo)) {
                        throw new \Exception('Parámetros requeridos: periodo, axo');
                    }
                    $labels = [
                        1 => ['ENE. ', 'ENERO DE '],
                        2 => ['FEB. ', 'FEBRERO DE '],
                        3 => ['MAR. ', 'MARZO DE '],
                        4 => ['ABR. ', 'ABRIL DE '],
                        5 => ['MAY. ', 'MAYO DE '],
                        6 => ['JUN. ', 'JUNIO DE '],
                        7 => ['JUL. ', 'JULIO DE '],
                        8 => ['AGO. ', 'AGOSTO DE '],
                        9 => ['SEP. ', 'SEPTIEMBRE DE '],
                        10 => ['OCT. ', 'OCTUBRE DE '],
                        11 => ['NOV. ', 'NOVIEMBRE DE '],
                        12 => ['DIC. ', 'DICIEMBRE DE '],
                    ];
                    $label = $labels[$periodo] ?? ['', ''];
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'short' => $label[0] . $axo,
                        'long' => $label[1] . $axo
                    ];
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json($eResponse);
    }
}
