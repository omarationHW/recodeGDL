<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class AdeudosInsController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'adeudos_ins_get_catalogs':
                    $response['data'] = [
                        'tipo_aseo' => DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM cat_tipo_aseo ORDER BY ctrol_aseo'),
                        'tipo_operacion' => DB::select('SELECT ctrol_operacion, cve_operacion, descripcion FROM cat_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion'),
                        'meses' => [
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
                        ]
                    ];
                    $response['success'] = true;
                    break;
                case 'adeudos_ins_validate_contrato':
                    $contrato = $params['contrato'] ?? null;
                    $ctrol_aseo = $params['ctrol_aseo'] ?? null;
                    $ejercicio = $params['ejercicio'] ?? null;
                    $row = DB::selectOne('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ? AND status_vigencia = ? AND EXTRACT(YEAR FROM aso_mes_oblig) <= ?', [$contrato, $ctrol_aseo, 'V', $ejercicio]);
                    $response['data'] = $row;
                    $response['success'] = $row ? true : false;
                    $response['message'] = $row ? '' : 'Contrato no encontrado o no vigente';
                    break;
                case 'adeudos_ins_insert':
                    $validator = Validator::make($params, [
                        'contrato' => 'required|integer',
                        'ctrol_aseo' => 'required|integer',
                        'ejercicio' => 'required|integer',
                        'aso' => 'required|integer',
                        'mes' => 'required|string',
                        'ctrol_operacion' => 'required|integer',
                        'exedencias' => 'required|integer|min:1',
                        'oficio' => 'nullable|string|max:15'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $contrato = $params['contrato'];
                    $ctrol_aseo = $params['ctrol_aseo'];
                    $ejercicio = $params['ejercicio'];
                    $aso = $params['aso'];
                    $mes = $params['mes'];
                    $ctrol_operacion = $params['ctrol_operacion'];
                    $exedencias = $params['exedencias'];
                    $oficio = $params['oficio'] ?? '0';
                    // Validaciones de negocio
                    $contratoRow = DB::selectOne('SELECT c.control_contrato, c.costo_exed, c.aso_mes_oblig FROM ta_16_contratos c WHERE c.num_contrato = ? AND c.ctrol_aseo = ? AND EXTRACT(YEAR FROM c.aso_mes_oblig) <= ?', [$contrato, $ctrol_aseo, $aso]);
                    if (!$contratoRow) {
                        $response['message'] = 'Contrato no encontrado o fuera de rango de ejercicio';
                        break;
                    }
                    $fecha_oblig = $contratoRow->aso_mes_oblig;
                    $fecha_cap = sprintf('%04d-%02d-01', $aso, intval($mes));
                    if ($fecha_cap < $fecha_oblig) {
                        $response['message'] = 'La fecha de exedencia es menor al inicio de obligación';
                        break;
                    }
                    // Validar cuota normal
                    $cuotaNormal = DB::selectOne('SELECT 1 FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = 6 AND (status_vigencia = ? OR status_vigencia = ?)', [$contratoRow->control_contrato, $fecha_cap, 'V', 'P']);
                    if (!$cuotaNormal) {
                        $response['message'] = 'No existe cuota normal para el periodo';
                        break;
                    }
                    // Validar que no exista exedencia
                    $exed = DB::selectOne('SELECT 1 FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia <> ?', [$contratoRow->control_contrato, $fecha_cap, $ctrol_operacion, 'Z']);
                    if ($exed) {
                        $response['message'] = 'Ya existe exedencia/contenedor para este periodo';
                        break;
                    }
                    // Validar rango de año
                    $ejercicio_actual = intval(date('Y'));
                    if ($aso < 1989 || $aso > $ejercicio_actual) {
                        $response['message'] = 'Año fuera de rango permitido';
                        break;
                    }
                    // Insertar
                    DB::beginTransaction();
                    try {
                        $importe = $exedencias * $contratoRow->costo_exed;
                        DB::insert('INSERT INTO ta_16_pagos (control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias) VALUES (?, ?, ?, ?, ?, NOW(), 0, \'\', 0, ?, ?, ?)', [
                            $contratoRow->control_contrato,
                            $fecha_cap,
                            $ctrol_operacion,
                            $importe,
                            'V',
                            $oficio,
                            $userId,
                            $exedencias
                        ]);
                        DB::commit();
                        $response['success'] = true;
                        $response['message'] = 'Exedencia registrada correctamente';
                    } catch (\Exception $e) {
                        DB::rollBack();
                        $response['message'] = 'Error al grabar exedencia: ' . $e->getMessage();
                    }
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
