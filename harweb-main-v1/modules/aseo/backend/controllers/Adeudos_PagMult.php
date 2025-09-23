<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class AdeudosPagMultController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Adeudos_PagMult
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar_catalogos|buscar_contrato|listar_adeudos|pagar_adeudos",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? '';
        $response = [];
        try {
            switch ($action) {
                case 'listar_catalogos':
                    $response = $this->listarCatalogos();
                    break;
                case 'buscar_contrato':
                    $contrato = $input['contrato'] ?? null;
                    $ctrol_aseo = $input['ctrol_aseo'] ?? null;
                    $response = $this->buscarContrato($contrato, $ctrol_aseo);
                    break;
                case 'listar_adeudos':
                    $control_contrato = $input['control_contrato'] ?? null;
                    $response = $this->listarAdeudos($control_contrato);
                    break;
                case 'pagar_adeudos':
                    $params = $input['params'] ?? [];
                    $response = $this->pagarAdeudos($params);
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }

    /**
     * Listar catálogos necesarios para el formulario
     */
    private function listarCatalogos()
    {
        $tipos_aseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $recaudadoras = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        $cajas = DB::select('SELECT DISTINCT caja FROM ta_12_operaciones ORDER BY caja');
        return [
            'tipos_aseo' => $tipos_aseo,
            'recaudadoras' => $recaudadoras,
            'cajas' => $cajas
        ];
    }

    /**
     * Buscar contrato por número y tipo de aseo
     */
    private function buscarContrato($contrato, $ctrol_aseo)
    {
        $result = DB::selectOne('SELECT control_contrato, num_contrato, ctrol_aseo FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ?', [$contrato, $ctrol_aseo]);
        if (!$result) {
            throw new \Exception('Contrato no encontrado');
        }
        return [
            'contrato' => $result
        ];
    }

    /**
     * Listar adeudos vigentes de un contrato
     */
    private function listarAdeudos($control_contrato)
    {
        $adeudos = DB::select('SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.cve_operacion, b.descripcion, a.exedencias, a.importe FROM ta_16_pagos a JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion WHERE a.control_contrato = ? AND a.status_vigencia = ? ORDER BY a.aso_mes_pago', [$control_contrato, 'V']);
        return [
            'adeudos' => $adeudos
        ];
    }

    /**
     * Pagar adeudos seleccionados
     * params: {
     *   "adeudos": [ { "control_contrato":..., "aso_mes_pago":..., "ctrol_operacion":... }, ... ],
     *   "fecha_pagado": "YYYY-MM-DD HH:MM",
     *   "id_rec": ..., "caja": ..., "consec_operacion": ..., "folio_rcbo": ..., "usuario": ...
     * }
     */
    private function pagarAdeudos($params)
    {
        $adeudos = $params['adeudos'] ?? [];
        $fecha_pagado = $params['fecha_pagado'] ?? null;
        $id_rec = $params['id_rec'] ?? null;
        $caja = $params['caja'] ?? null;
        $consec_operacion = $params['consec_operacion'] ?? null;
        $folio_rcbo = $params['folio_rcbo'] ?? null;
        $usuario = $params['usuario'] ?? null;
        if (empty($adeudos)) {
            throw new \Exception('No hay adeudos seleccionados');
        }
        DB::beginTransaction();
        try {
            foreach ($adeudos as $ad) {
                DB::update('UPDATE ta_16_pagos SET status_vigencia = ?, fecha_hora_pago = ?, id_rec = ?, caja = ?, consec_operacion = ?, folio_rcbo = ?, usuario = ? WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia = ?', [
                    'P', $fecha_pagado, $id_rec, $caja, $consec_operacion, $folio_rcbo, $usuario,
                    $ad['control_contrato'], $ad['aso_mes_pago'], $ad['ctrol_operacion'], 'V'
                ]);
            }
            DB::commit();
            return ['success' => true];
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
