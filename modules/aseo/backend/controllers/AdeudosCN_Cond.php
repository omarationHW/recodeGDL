<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AdeudosCNCondController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;

        switch ($action) {
            case 'getCatalogs':
                return response()->json([
                    'tipoAseo' => DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo'),
                    'tipoOperacion' => DB::select('SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY ctrol_operacion')
                ]);
            case 'getContratoInfo':
                $contrato = DB::selectOne('SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, b.costo_unidad, a.aso_mes_oblig FROM ta_16_contratos a JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec WHERE a.num_contrato = ? AND a.ctrol_aseo = ?', [
                    $params['num_contrato'], $params['ctrol_aseo']
                ]);
                return response()->json($contrato);
            case 'checkExedenciaVigente':
                $row = DB::selectOne('SELECT 1 FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia = ? LIMIT 1', [
                    $params['control_contrato'], $params['aso_mes_pago'], $params['ctrol_operacion'], 'V'
                ]);
                return response()->json(['exists' => !!$row]);
            case 'condonarAdeudo':
                return $this->condonarAdeudo($params, $userId);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    /**
     * Ejecuta la condonación de adeudo
     */
    private function condonarAdeudo($params, $userId)
    {
        $contrato = DB::selectOne('SELECT a.control_contrato FROM ta_16_contratos a WHERE a.num_contrato = ? AND a.ctrol_aseo = ?', [
            $params['num_contrato'], $params['ctrol_aseo']
        ]);
        if (!$contrato) {
            return response()->json(['success' => false, 'message' => 'No existe el contrato.'], 404);
        }
        $pagos = DB::select('SELECT * FROM ta_16_pagos WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia = ?', [
            $contrato->control_contrato, $params['aso_mes_pago'], $params['ctrol_operacion'], 'V'
        ]);
        if (empty($pagos)) {
            return response()->json(['success' => false, 'message' => 'No existe EXEDENCIA vigente para condonar.'], 404);
        }
        try {
            DB::beginTransaction();
            DB::update('UPDATE ta_16_pagos SET status_vigencia = ?, fecha_hora_pago = NOW(), usuario = ?, folio_rcbo = ? WHERE control_contrato = ? AND aso_mes_pago = ? AND ctrol_operacion = ? AND status_vigencia = ?', [
                'S', $userId, $params['oficio'], $contrato->control_contrato, $params['aso_mes_pago'], $params['ctrol_operacion'], 'V'
            ]);
            DB::commit();
            return response()->json(['success' => true, 'message' => 'Condonación realizada correctamente.']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error al condonar: ' . $e->getMessage()], 500);
        }
    }
}
