<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class AdeudosExeDelController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario AdeudosExe_Del
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|delete|logic_delete",
     *     "contrato": int,
     *     "ctrol_aseo": int,
     *     "aso": int,
     *     "mes": int,
     *     "ctrol_operacion": int,
     *     "oficio": string,
     *     "usuario_id": int
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        switch ($action) {
            case 'list':
                $response = $this->listContrato($input);
                break;
            case 'delete':
                $response = $this->deleteFisica($input);
                break;
            case 'logic_delete':
                $response = $this->deleteLogica($input);
                break;
            default:
                $response = ["success" => false, "message" => "Acción no soportada", "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function listContrato($input)
    {
        $contrato = $input['contrato'] ?? null;
        $ctrol_aseo = $input['ctrol_aseo'] ?? null;
        if (!$contrato || !$ctrol_aseo) {
            return ["success" => false, "message" => "Datos insuficientes", "data" => null];
        }
        $row = DB::table('ta_16_contratos as a')
            ->join('ta_16_unidades as b', 'a.ctrol_recolec', '=', 'b.ctrol_recolec')
            ->select('a.control_contrato', 'a.num_contrato', 'a.ctrol_aseo', 'a.ctrol_recolec', 'b.costo_unidad', 'a.aso_mes_oblig')
            ->where('a.num_contrato', $contrato)
            ->where('a.ctrol_aseo', $ctrol_aseo)
            ->first();
        if (!$row) {
            return ["success" => false, "message" => "Contrato no encontrado", "data" => null];
        }
        return ["success" => true, "message" => "Contrato encontrado", "data" => $row];
    }

    private function deleteFisica($input)
    {
        $validator = Validator::make($input, [
            'contrato' => 'required|integer',
            'ctrol_aseo' => 'required|integer',
            'aso' => 'required|integer',
            'mes' => 'required|integer',
            'ctrol_operacion' => 'required|integer',
            'usuario_id' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $contrato = $input['contrato'];
        $ctrol_aseo = $input['ctrol_aseo'];
        $aso = $input['aso'];
        $mes = $input['mes'];
        $ctrol_operacion = $input['ctrol_operacion'];
        $periodo = sprintf("%d-%02d", $aso, $mes);
        $row = DB::table('ta_16_contratos as a')
            ->where('a.num_contrato', $contrato)
            ->where('a.ctrol_aseo', $ctrol_aseo)
            ->first();
        if (!$row) {
            return ["success" => false, "message" => "Contrato no encontrado", "data" => null];
        }
        try {
            DB::beginTransaction();
            $deleted = DB::table('ta_16_pagos')
                ->where('control_contrato', $row->control_contrato)
                ->where('aso_mes_pago', $periodo)
                ->where('ctrol_operacion', $ctrol_operacion)
                ->where('status_vigencia', 'V')
                ->delete();
            DB::commit();
            return ["success" => true, "message" => "Baja física realizada", "data" => ["deleted" => $deleted]];
        } catch (\Exception $e) {
            DB::rollBack();
            return ["success" => false, "message" => "Error al borrar: " . $e->getMessage(), "data" => null];
        }
    }

    private function deleteLogica($input)
    {
        $validator = Validator::make($input, [
            'contrato' => 'required|integer',
            'ctrol_aseo' => 'required|integer',
            'aso' => 'required|integer',
            'mes' => 'required|integer',
            'ctrol_operacion' => 'required|integer',
            'oficio' => 'required|string',
            'usuario_id' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $contrato = $input['contrato'];
        $ctrol_aseo = $input['ctrol_aseo'];
        $aso = $input['aso'];
        $mes = $input['mes'];
        $ctrol_operacion = $input['ctrol_operacion'];
        $oficio = $input['oficio'];
        $usuario_id = $input['usuario_id'];
        $periodo = sprintf("%d-%02d", $aso, $mes);
        $row = DB::table('ta_16_contratos as a')
            ->where('a.num_contrato', $contrato)
            ->where('a.ctrol_aseo', $ctrol_aseo)
            ->first();
        if (!$row) {
            return ["success" => false, "message" => "Contrato no encontrado", "data" => null];
        }
        try {
            DB::beginTransaction();
            $updated = DB::table('ta_16_pagos')
                ->where('control_contrato', $row->control_contrato)
                ->where('aso_mes_pago', $periodo)
                ->where('ctrol_operacion', $ctrol_operacion)
                ->where('status_vigencia', 'V')
                ->update([
                    'status_vigencia' => 'B',
                    'usuario' => $usuario_id,
                    'folio_rcbo' => $oficio
                ]);
            DB::commit();
            return ["success" => true, "message" => "Baja lógica realizada", "data" => ["updated" => $updated]];
        } catch (\Exception $e) {
            DB::rollBack();
            return ["success" => false, "message" => "Error al actualizar: " . $e->getMessage(), "data" => null];
        }
    }
}
