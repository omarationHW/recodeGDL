<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosMultInsController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'getCatalogs':
                return response()->json($this->getCatalogs());
            case 'getSheetTemplate':
                return response()->json($this->getSheetTemplate());
            case 'validateSheet':
                return response()->json($this->validateSheet($params));
            case 'saveSheet':
                return response()->json($this->saveSheet($params, $userId));
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    /**
     * Devuelve catálogos necesarios para el formulario
     */
    private function getCatalogs()
    {
        $tiposAseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $tiposOper = DB::select('SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion');
        $meses = [
            ['value' => '01', 'label' => 'Enero'], ['value' => '02', 'label' => 'Febrero'],
            ['value' => '03', 'label' => 'Marzo'], ['value' => '04', 'label' => 'Abril'],
            ['value' => '05', 'label' => 'Mayo'], ['value' => '06', 'label' => 'Junio'],
            ['value' => '07', 'label' => 'Julio'], ['value' => '08', 'label' => 'Agosto'],
            ['value' => '09', 'label' => 'Septiembre'], ['value' => '10', 'label' => 'Octubre'],
            ['value' => '11', 'label' => 'Noviembre'], ['value' => '12', 'label' => 'Diciembre']
        ];
        return [
            'tiposAseo' => $tiposAseo,
            'tiposOper' => $tiposOper,
            'meses' => $meses
        ];
    }

    /**
     * Devuelve la plantilla de hoja de cálculo (cabeceras)
     */
    private function getSheetTemplate()
    {
        return [
            'columns' => [
                ['key' => 'contrato', 'label' => 'CONTRATO', 'type' => 'integer'],
                ['key' => 'excedencia', 'label' => 'EXCEDENCIA', 'type' => 'integer']
            ]
        ];
    }

    /**
     * Valida la hoja de cálculo antes de grabar
     */
    private function validateSheet($params)
    {
        $errors = [];
        $anio = $params['anio'] ?? null;
        $mes = $params['mes'] ?? null;
        $tipoAseo = $params['tipoAseo'] ?? null;
        $tipoOper = $params['tipoOper'] ?? null;
        $oficio = $params['oficio'] ?? null;
        $rows = $params['rows'] ?? [];

        if (!$anio || !$mes || !$tipoAseo || !$tipoOper) {
            return ['valid' => false, 'errors' => ['Faltan parámetros obligatorios']];
        }
        foreach ($rows as $i => $row) {
            if (empty($row['contrato']) || empty($row['excedencia'])) {
                $errors[] = "Fila ".($i+1).": Contrato y Excedencia son obligatorios";
            } else if (!is_numeric($row['contrato']) || !is_numeric($row['excedencia'])) {
                $errors[] = "Fila ".($i+1).": Contrato y Excedencia deben ser numéricos";
            }
        }
        return [
            'valid' => count($errors) === 0,
            'errors' => $errors
        ];
    }

    /**
     * Procesa y graba la hoja de cálculo
     */
    private function saveSheet($params, $userId)
    {
        $anio = $params['anio'] ?? null;
        $mes = $params['mes'] ?? null;
        $tipoAseo = $params['tipoAseo'] ?? null;
        $tipoOper = $params['tipoOper'] ?? null;
        $oficio = $params['oficio'] ?? null;
        $rows = $params['rows'] ?? [];
        $errores = [];
        $bienGrabado = true;
        DB::beginTransaction();
        try {
            foreach ($rows as $i => $row) {
                $contrato = $row['contrato'];
                $excedencia = $row['excedencia'];
                // 1. Buscar contrato y costo_exed
                $contratoRow = DB::selectOne('SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, c.costo_exed, a.aso_mes_oblig FROM ta_16_contratos a JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = ? WHERE a.num_contrato = ? AND a.ctrol_aseo = ?', [$anio, $contrato, $tipoAseo]);
                if (!$contratoRow) {
                    $errores[] = "Contrato $contrato no existe o no corresponde al tipo de aseo";
                    $bienGrabado = false;
                    continue;
                }
                // 2. Verificar cuota normal
                $cuotaNormal = DB::selectOne('SELECT * FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = 6 AND (status_vigencia = \'V\' OR status_vigencia = \'P\')', [$contratoRow->control_contrato, "$anio-$mes"]);
                if (!$cuotaNormal) {
                    $errores[] = "Contrato $contrato: No existe cuota normal para el periodo";
                    $bienGrabado = false;
                    continue;
                }
                // 3. Verificar si ya existe excedente
                $exed = DB::selectOne('SELECT * FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ?', [$contratoRow->control_contrato, "$anio-$mes", $tipoOper]);
                if ($exed) {
                    $errores[] = "Contrato $contrato: Ya existe excedente para el periodo";
                    $bienGrabado = false;
                    continue;
                }
                // 4. Insertar nuevo excedente
                DB::insert('INSERT INTO ta_16_pagos (control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, 0, \'\', 0, ?, ?, ?)', [
                    $contratoRow->control_contrato,
                    "$anio-$mes",
                    $tipoOper,
                    $excedencia * $contratoRow->costo_exed,
                    'V',
                    $oficio,
                    $userId,
                    $excedencia
                ]);
            }
            if ($bienGrabado) {
                DB::commit();
                return ['success' => true, 'message' => 'Carga de Excedencias exitosa'];
            } else {
                DB::rollBack();
                return ['success' => false, 'message' => 'Errores en la carga', 'errors' => $errores];
            }
        } catch (\Exception $e) {
            DB::rollBack();
            return ['success' => false, 'message' => 'Error en la carga: ' . $e->getMessage()];
        }
    }
}
