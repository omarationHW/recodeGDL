<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class AdeudosUpdExedController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Adeudos_UpdExed
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|update|reset|catalogs",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? '';
        $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];

        try {
            switch ($action) {
                case 'catalogs':
                    $response = $this->getCatalogs();
                    break;
                case 'search':
                    $response = $this->searchExcedencia($input);
                    break;
                case 'update':
                    $response = $this->updateExcedencia($input);
                    break;
                case 'reset':
                    $response = ["success" => true, "message" => "Formulario reiniciado", "data" => null];
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];
            }
        } catch (\Exception $e) {
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }

        return response()->json(["eResponse" => $response]);
    }

    private function getCatalogs()
    {
        $tiposAseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $tiposOperacion = DB::select('SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion');
        $meses = [];
        for ($i = 1; $i <= 12; $i++) {
            $meses[] = str_pad($i, 2, '0', STR_PAD_LEFT);
        }
        return [
            "success" => true,
            "message" => "Catálogos cargados",
            "data" => [
                "tiposAseo" => $tiposAseo,
                "tiposOperacion" => $tiposOperacion,
                "meses" => $meses
            ]
        ];
    }

    private function searchExcedencia($input)
    {
        $contrato = intval($input['contrato'] ?? 0);
        $ctrolAseo = intval($input['ctrol_aseo'] ?? 0);
        $ejercicio = intval($input['ejercicio'] ?? 0);
        $mes = intval($input['mes'] ?? 0);
        $ctrolOperacion = intval($input['ctrol_operacion'] ?? 0);

        // Validación básica
        if (!$contrato || !$ctrolAseo || !$ejercicio || !$mes || !$ctrolOperacion) {
            return ["success" => false, "message" => "Datos incompletos", "data" => null];
        }

        // Buscar contrato
        $contratoRow = DB::selectOne('SELECT control_contrato, num_contrato, ctrol_aseo, ctrol_recolec, costo_exed, aso_mes_oblig FROM ta_16_contratos a JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = ? WHERE a.num_contrato = ? AND a.ctrol_aseo = ?', [$ejercicio, $contrato, $ctrolAseo]);
        if (!$contratoRow) {
            return ["success" => false, "message" => "No existe CONTRATO, intenta con otro", "data" => null];
        }

        $periodo = sprintf("%04d-%02d", $ejercicio, $mes);
        $exed = DB::selectOne('SELECT * FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia = ? LIMIT 1', [
            $contratoRow->control_contrato, $periodo, $ctrolOperacion, 'V'
        ]);
        if (!$exed) {
            return ["success" => false, "message" => "No Existe exedencia en el PERIODO y/o MOVIMIENTO proporcionados o no está VIGENTE, intenta con otro", "data" => null];
        }

        return [
            "success" => true,
            "message" => "Excedencia encontrada",
            "data" => [
                "contrato" => $contratoRow,
                "excedencia" => $exed
            ]
        ];
    }

    private function updateExcedencia($input)
    {
        $contrato = intval($input['contrato'] ?? 0);
        $ctrolAseo = intval($input['ctrol_aseo'] ?? 0);
        $ejercicio = intval($input['ejercicio'] ?? 0);
        $mes = intval($input['mes'] ?? 0);
        $ctrolOperacion = intval($input['ctrol_operacion'] ?? 0);
        $cantidad = intval($input['cantidad'] ?? 0);
        $oficio = trim($input['oficio'] ?? '0');
        $usuario = intval($input['usuario'] ?? 0); // Debe venir del token/session

        // Buscar contrato y costo_exed
        $contratoRow = DB::selectOne('SELECT control_contrato, costo_exed FROM ta_16_contratos a JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = ? WHERE a.num_contrato = ? AND a.ctrol_aseo = ?', [$ejercicio, $contrato, $ctrolAseo]);
        if (!$contratoRow) {
            return ["success" => false, "message" => "No existe CONTRATO, intenta con otro", "data" => null];
        }
        $periodo = sprintf("%04d-%02d", $ejercicio, $mes);
        $importe = $cantidad * floatval($contratoRow->costo_exed);

        DB::beginTransaction();
        try {
            $affected = DB::update('UPDATE ta_16_pagos SET importe = ?, folio_rcbo = ?, usuario = ?, exedencias = ? WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia = ?', [
                $importe, $oficio, $usuario, $cantidad, $contratoRow->control_contrato, $periodo, $ctrolOperacion, 'V'
            ]);
            DB::commit();
            if ($affected) {
                return ["success" => true, "message" => "Excedencia actualizada correctamente", "data" => null];
            } else {
                return ["success" => false, "message" => "No se actualizó ningún registro", "data" => null];
            }
        } catch (\Exception $e) {
            DB::rollBack();
            return ["success" => false, "message" => "Error al actualizar EXCEDENCIA: " . $e->getMessage(), "data" => null];
        }
    }
}
