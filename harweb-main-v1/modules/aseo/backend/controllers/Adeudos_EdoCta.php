<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosEdoCtaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Adeudos_EdoCta
     * Entrada: {
     *   eRequest: {
     *     action: string, // 'init', 'getTipoAseo', 'getContratos', 'procesarAdeudos', ...
     *     params: {...}
     *   }
     * }
     * Salida: {
     *   eResponse: {...}
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [];

        try {
            switch ($action) {
                case 'init':
                    $eResponse['tipoAseo'] = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $eResponse['meses'] = [
                        ['value' => '01', 'label' => 'Enero'],
                        ['value' => '02', 'label' => 'Febrero'],
                        ['value' => '03', 'label' => 'Marzo'],
                        ['value' => '04', 'label' => 'Abril'],
                        ['value' => '05', 'label' => 'Mayo'],
                        ['value' => '06', 'label' => 'Junio'],
                        ['value' => '07', 'label' => 'Julio'],
                        ['value' => '08', 'label' => 'Agosto'],
                        ['value' => '09', 'label' => 'Septiembre'],
                        ['value' => '10', 'label' => 'Octubre'],
                        ['value' => '11', 'label' => 'Noviembre'],
                        ['value' => '12', 'label' => 'Diciembre']
                    ];
                    $eResponse['vigencias'] = [
                        ['value' => 'V', 'label' => 'Periodos Vigentes'],
                        ['value' => 'A', 'label' => 'Otro Periodo']
                    ];
                    break;
                case 'getTipoAseo':
                    $eResponse['tipoAseo'] = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    break;
                case 'getContratos':
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    $vigencia = $params['vigencia'] ?? 'V';
                    $sql = "SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ? AND status_vigencia = ? ORDER BY ctrol_aseo, num_contrato";
                    $eResponse['contratos'] = DB::select($sql, [$contrato, $ctrol_aseo, $vigencia]);
                    break;
                case 'procesarAdeudos':
                    // Lógica principal: genera detalle de pagos, apremios, etc.
                    $contrato = $params['contrato'];
                    $ctrol_aseo = $params['ctrol_aseo'];
                    $vigencia = $params['vigencia'] ?? 'V';
                    $ejercicio = $params['ejercicio'] ?? date('Y');
                    $mes = $params['mes'] ?? date('m');
                    $tipo_periodo = $params['tipo_periodo'] ?? 'V'; // V=vigentes, A=otro periodo

                    // 1. Ejecutar sp_creadetp (crea detalle de pagos)
                    DB::statement('CALL sp_creadetp()');

                    // 2. Buscar contratos
                    $contratos = DB::select(
                        'SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ? AND status_vigencia = ? ORDER BY ctrol_aseo, num_contrato',
                        [$contrato, $ctrol_aseo, $vigencia]
                    );
                    if (empty($contratos)) {
                        $eResponse['error'] = 'No existen contratos con estos datos';
                        break;
                    }
                    $resultados = [];
                    foreach ($contratos as $cont) {
                        // 3. Ejecutar sp_detapremios (apremios por contrato)
                        DB::statement('CALL sp_detapremios(?)', [$cont->control_contrato]);
                        // 4. Ejecutar sp_detpagos (detalle de pagos por contrato)
                        DB::statement('CALL sp_detpagos(?, ?, ?, ?, ?, ?)', [
                            $cont->control_contrato,
                            $ejercicio,
                            $ejercicio.'-'.$mes,
                            $ejercicio.'-'.$mes,
                            $ejercicio.'-'.$mes,
                            $vigencia
                        ]);
                        // 5. Consultar detalle de pagos
                        $detPagos = DB::select('SELECT * FROM det_pagos WHERE control_contrato = ?', [$cont->control_contrato]);
                        $detPagosSum = DB::select('SELECT SUM(importe_adeudos) as total_adeudos, SUM(importe_recargos) as total_recargos FROM det_pagos WHERE control_contrato = ?', [$cont->control_contrato]);
                        $resultados[] = [
                            'contrato' => $cont,
                            'detPagos' => $detPagos,
                            'detPagosSum' => $detPagosSum[0] ?? null
                        ];
                    }
                    $eResponse['resultados'] = $resultados;
                    break;
                case 'getDetallePagos':
                    $control_contrato = $params['control_contrato'];
                    $eResponse['detPagos'] = DB::select('SELECT * FROM det_pagos WHERE control_contrato = ?', [$control_contrato]);
                    $eResponse['detPagosSum'] = DB::select('SELECT SUM(importe_adeudos) as total_adeudos, SUM(importe_recargos) as total_recargos FROM det_pagos WHERE control_contrato = ?', [$control_contrato]);
                    break;
                default:
                    $eResponse['error'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['error'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
