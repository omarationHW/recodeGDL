<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosNvoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'status' => 'error',
                'message' => 'Acción no reconocida',
                'data' => null
            ]
        ];

        try {
            switch ($action) {
                case 'getTipoAseo':
                    $data = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => $data
                    ];
                    break;
                case 'getContrato':
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    if (!$contrato || !$ctrol_aseo) {
                        throw new \Exception('Faltan parámetros');
                    }
                    $data = DB::select('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ?', [$contrato, $ctrol_aseo]);
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => $data
                    ];
                    break;
                case 'getAdeudosVigencias':
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => [
                            ['value' => 'V', 'label' => 'Periodos Vencidos'],
                            ['value' => 'O', 'label' => 'Otro Periodo']
                        ]
                    ];
                    break;
                case 'getMeses':
                    $meses = [];
                    for ($i = 1; $i <= 12; $i++) {
                        $meses[] = [
                            'value' => str_pad($i, 2, '0', STR_PAD_LEFT),
                            'label' => str_pad($i, 2, '0', STR_PAD_LEFT)
                        ];
                    }
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => $meses
                    ];
                    break;
                case 'getEstadoCuenta':
                    // Llama el SP principal para el reporte
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    $vigencia = $params['vigencia'] ?? 'V';
                    $anio = $params['anio'] ?? null;
                    $mes = $params['mes'] ?? null;
                    if (!$contrato || !$ctrol_aseo) {
                        throw new \Exception('Faltan parámetros');
                    }
                    $periodo = $anio && $mes ? $anio.'-'.$mes : null;
                    $result = DB::select('SELECT * FROM con16_detade_01(:contrato, :vigencia, :periodo)', [
                        'contrato' => $contrato,
                        'vigencia' => $vigencia,
                        'periodo' => $periodo
                    ]);
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => $result
                    ];
                    break;
                case 'getEstadoCuentaDetallado':
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    $vigencia = $params['vigencia'] ?? 'V';
                    $anio = $params['anio'] ?? null;
                    $mes = $params['mes'] ?? null;
                    if (!$contrato || !$ctrol_aseo) {
                        throw new \Exception('Faltan parámetros');
                    }
                    $periodo = $anio && $mes ? $anio.'-'.$mes : null;
                    $result = DB::select('SELECT * FROM con16_detade_02(:contrato, :vigencia, :periodo)', [
                        'contrato' => $contrato,
                        'vigencia' => $vigencia,
                        'periodo' => $periodo
                    ]);
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => $result
                    ];
                    break;
                case 'getEstadoCuentaF02':
                    $tipo = $params['tipo'] ?? null;
                    $numero = $params['numero'] ?? null;
                    $rep = $params['rep'] ?? null;
                    $pref = $params['pref'] ?? null;
                    if (!$tipo || !$numero || !$rep || !$pref) {
                        throw new \Exception('Faltan parámetros');
                    }
                    $result = DB::select('SELECT * FROM sp16_adeudos_f02(:tipo, :numero, :rep, :pref)', [
                        'tipo' => $tipo,
                        'numero' => $numero,
                        'rep' => $rep,
                        'pref' => $pref
                    ]);
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'data' => $result
                    ];
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse'] = [
                'status' => 'error',
                'message' => $e->getMessage(),
                'data' => null
            ];
        }
        return response()->json($response);
    }
}
