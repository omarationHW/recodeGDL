<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DetallePagosDiversosController extends Controller
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
                case 'getPagosDiversosDetalle':
                    $response['data'] = $this->getPagosDiversosDetalle($params);
                    $response['success'] = true;
                    break;
                case 'getDesgloceCuentas':
                    $response['data'] = $this->getDesgloceCuentas($params);
                    $response['success'] = true;
                    break;
                case 'getResumenTotales':
                    $response['data'] = $this->getResumenTotales($params);
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
     * Obtiene el detalle de pagos diversos para un convenio/resto
     * params: [id_conv_resto]
     */
    private function getPagosDiversosDetalle($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Parámetro id_conv_resto requerido');
        }
        $result = DB::select('SELECT *,
            (SELECT SUM(importe) FROM ta_12_recibosdet WHERE fecha=a.fecha_pago AND id_rec=a.oficina_pago AND caja=a.caja_pago AND operacion=a.operacion_pago AND cuenta IN (46508,550200000,551100000)) AS intereses
            FROM ta_17_conv_pagos a
            LEFT JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
            LEFT JOIN ta_17_adeudos_div c ON a.id_conv_resto = c.id_conv_resto AND a.pago_parcial = c.pago_parcial
            LEFT JOIN ta_12_recibos d ON d.fecha = a.fecha_pago AND d.id_rec = a.oficina_pago AND d.caja = a.caja_pago AND d.operacion = a.operacion_pago
            WHERE a.id_conv_resto = ?
            ORDER BY a.id_conv_resto ASC, a.pago_parcial', [$id_conv_resto]);
        return $result;
    }

    /**
     * Obtiene el desgloce de cuentas para un id_adeudo
     * params: [id_adeudo]
     */
    private function getDesgloceCuentas($params)
    {
        $id_adeudo = $params['id_adeudo'] ?? null;
        if (!$id_adeudo) {
            throw new \Exception('Parámetro id_adeudo requerido');
        }
        $result = DB::select('SELECT importe, cuenta_apl, descripcion FROM ta_17_desg_parcial WHERE id_adeudo = ?', [$id_adeudo]);
        return $result;
    }

    /**
     * Obtiene resumen de totales (pagado, recargos, intereses) para un id_conv_resto
     * params: [id_conv_resto]
     */
    private function getResumenTotales($params)
    {
        $id_conv_resto = $params['id_conv_resto'] ?? null;
        if (!$id_conv_resto) {
            throw new \Exception('Parámetro id_conv_resto requerido');
        }
        $pagos = DB::select('SELECT importe_pago, importe_recargo, (SELECT SUM(importe) FROM ta_12_recibosdet WHERE fecha=a.fecha_pago AND id_rec=a.oficina_pago AND caja=a.caja_pago AND operacion=a.operacion_pago AND cuenta IN (46508,550200000,551100000)) AS intereses FROM ta_17_conv_pagos a WHERE id_conv_resto = ?', [$id_conv_resto]);
        $totpago = 0;
        $totbonif = 0;
        $totintereses = 0;
        foreach ($pagos as $p) {
            $totpago += $p->importe_pago;
            $totbonif += $p->importe_recargo;
            $totintereses += $p->intereses;
        }
        return [
            'total_pagado' => $totpago,
            'total_recargos' => $totbonif,
            'total_intereses' => $totintereses
        ];
    }
}
