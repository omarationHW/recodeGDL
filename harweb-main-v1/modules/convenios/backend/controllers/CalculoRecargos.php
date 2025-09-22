<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CalculoRecargosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getContrato':
                    $response['data'] = $this->getContrato($params);
                    $response['success'] = true;
                    break;
                case 'getRequerimientos':
                    $response['data'] = $this->getRequerimientos($params);
                    $response['success'] = true;
                    break;
                case 'getRecargos':
                    $response['data'] = $this->getRecargos($params);
                    $response['success'] = true;
                    break;
                case 'calcularRecargos':
                    $response['data'] = $this->calcularRecargos($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Obtener datos del contrato
     */
    private function getContrato($params)
    {
        $id_convenio = $params['id_convenio'] ?? null;
        if (!$id_convenio) {
            throw new \Exception('id_convenio es requerido');
        }
        $contrato = DB::selectOne('SELECT id_convenio, pago_inicial, pago_quincenal, pagos_parciales, fecha_vencimiento FROM ta_17_convenios WHERE id_convenio = ?', [$id_convenio]);
        return $contrato;
    }

    /**
     * Obtener requerimientos (apremios) del contrato
     */
    private function getRequerimientos($params)
    {
        $id_convenio = $params['id_convenio'] ?? null;
        if (!$id_convenio) {
            throw new \Exception('id_convenio es requerido');
        }
        $requerimientos = DB::select('SELECT * FROM ta_15_apremios WHERE modulo = 17 AND control_otr = ?', [$id_convenio]);
        return $requerimientos;
    }

    /**
     * Obtener porcentaje de recargos
     */
    private function getRecargos($params)
    {
        $alov = $params['alov'] ?? null;
        $mesv = $params['mesv'] ?? null;
        $alo = $params['alo'] ?? null;
        $mes = $params['mes'] ?? null;
        $dia = $params['dia'] ?? null;
        $diav = $params['diav'] ?? null;
        if (is_null($alov) || is_null($mesv) || is_null($alo) || is_null($mes) || is_null($dia) || is_null($diav)) {
            throw new \Exception('Parámetros de fecha incompletos');
        }
        $sql = "SELECT SUM(porcentaje_parcial) AS porcentaje FROM ta_13_recargosrcm WHERE (axo = ? AND mes >= ?) " .
            ($alov == $alo ? "AND" : "OR") .
            " (axo = ? AND mes <= ?) OR (axo > ? AND axo < ?)";
        $mes_limit = ($dia <= $diav) ? ($mes - 1) : $mes;
        $result = DB::selectOne($sql, [$alov, $mesv, $alo, $mes_limit, $alov, $alo]);
        return $result;
    }

    /**
     * Calcular recargos según la lógica del formulario
     */
    private function calcularRecargos($params)
    {
        $id_convenio = $params['id_convenio'] ?? null;
        $pagos_parciales = $params['pagos_parciales'] ?? 0;
        $pago_inicial = $params['pago_inicial'] ?? 0;
        $pago_quincenal = $params['pago_quincenal'] ?? 0;
        $pagos_a_realizar = $params['pagos_a_realizar'] ?? 0;
        $pag_inicio = $params['pag_inicio'] ?? 0;
        $pag_parcial = $params['pag_parcial'] ?? 0;
        $fecha_vencimiento = $params['fecha_vencimiento'] ?? null;
        $fecha_actual = $params['fecha_actual'] ?? null;
        $alov = $params['alov'] ?? null;
        $mesv = $params['mesv'] ?? null;
        $diav = $params['diav'] ?? null;
        $alo = $params['alo'] ?? null;
        $mes = $params['mes'] ?? null;
        $dia = $params['dia'] ?? null;
        $porcentaje = $params['porcentaje'] ?? null;
        $requerimientos = $params['requerimientos'] ?? [];
        $porcentaje_recargos = $params['porcentaje_recargos'] ?? null;

        if ($pagos_a_realizar > $pagos_parciales) {
            throw new \Exception('Error... Los Pagos a Realizar Exceden de ' . $pagos_parciales);
        }

        $importe_a_pagar = $pag_inicio + $pag_parcial;
        $importerecargos = 0;
        $label_porc = '';

        // Lógica de cálculo de recargos
        if (strtotime($fecha_actual) > strtotime($fecha_vencimiento)) {
            if (empty($requerimientos)) {
                if ($porcentaje_recargos > 100) {
                    $importerecargos = ($importe_a_pagar * 100) / 100;
                    $label_porc = '100%';
                } else {
                    $importerecargos = ($importe_a_pagar * $porcentaje_recargos) / 100;
                    $label_porc = $porcentaje_recargos . '%';
                }
            } else {
                if ($porcentaje_recargos > 250) {
                    $importerecargos = ($importe_a_pagar * 250) / 100;
                    $label_porc = '250%';
                } else {
                    $importerecargos = ($importe_a_pagar * $porcentaje_recargos) / 100;
                    $label_porc = $porcentaje_recargos . '%';
                }
            }
        } else {
            $importerecargos = ($importe_a_pagar * $porcentaje_recargos) / 100;
            $label_porc = $porcentaje_recargos . '%';
        }
        if ($importerecargos > 0) {
            $importerecargos = floor($importerecargos * 100) / 100;
        }
        return [
            'importe_a_pagar' => $importe_a_pagar,
            'importerecargos' => $importerecargos,
            'label_porc' => $label_porc
        ];
    }
}
