<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AdeudosPagController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Adeudos_Pag
     * Entrada: {
     *   eRequest: {
     *     action: string, // ver_adeudos, ejecutar_pago, cancelar, cargar_catalogos
     *     params: {...} // parámetros según acción
     *   }
     * }
     * Salida: {
     *   eResponse: {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'ver_adeudos':
                    $response = $this->verAdeudos($params);
                    break;
                case 'ejecutar_pago':
                    $response = $this->ejecutarPago($params);
                    break;
                case 'cancelar':
                    $response = ["success" => true, "data" => null, "message" => "Operación cancelada"];
                    break;
                case 'cargar_catalogos':
                    $response = $this->cargarCatalogos();
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida"];
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response = ["success" => false, "message" => $e->getMessage()];
        }

        return response()->json(["eResponse" => $response]);
    }

    private function verAdeudos($params)
    {
        $validator = Validator::make($params, [
            'contrato' => 'required|integer',
            'tipo_aseo' => 'required|integer',
            'aso' => 'required|integer',
            'mes' => 'required|integer|min:1|max:12'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first()];
        }
        $contrato = $params['contrato'];
        $tipoAseo = $params['tipo_aseo'];
        $aso = $params['aso'];
        $mes = $params['mes'];

        $result = DB::select('SELECT * FROM sp_adeudos_pag_ver_adeudos(?, ?, ?, ?)', [
            $contrato, $tipoAseo, $aso, $mes
        ]);
        if (empty($result)) {
            return ["success" => false, "message" => "No existen adeudos para el periodo seleccionado."];
        }
        return ["success" => true, "data" => $result];
    }

    private function ejecutarPago($params)
    {
        $validator = Validator::make($params, [
            'contrato' => 'required|integer',
            'tipo_aseo' => 'required|integer',
            'aso' => 'required|integer',
            'mes' => 'required|integer|min:1|max:12',
            'consec_oper' => 'required|integer',
            'folio_rcbo' => 'required',
            'fecha_pagado' => 'required|date',
            'id_rec' => 'required|integer',
            'caja' => 'required',
            'usuario_id' => 'required|integer',
            'pagar_cn' => 'boolean',
            'pagar_exe' => 'boolean',
            'importe_cn' => 'nullable|numeric',
            'importe_exe' => 'nullable|numeric'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first()];
        }
        $result = DB::select('SELECT * FROM sp_adeudos_pag_ejecutar_pago(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $params['contrato'],
            $params['tipo_aseo'],
            $params['aso'],
            $params['mes'],
            $params['consec_oper'],
            $params['folio_rcbo'],
            $params['fecha_pagado'],
            $params['id_rec'],
            $params['caja'],
            $params['usuario_id'],
            $params['pagar_cn'] ?? false,
            $params['importe_cn'] ?? 0,
            $params['pagar_exe'] ?? false,
            $params['importe_exe'] ?? 0
        ]);
        if (isset($result[0]->success) && $result[0]->success) {
            return ["success" => true, "message" => $result[0]->message];
        }
        return ["success" => false, "message" => $result[0]->message ?? 'Error al ejecutar pago'];
    }

    private function cargarCatalogos()
    {
        $tipoAseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $recaudadoras = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        $cajas = DB::select('SELECT DISTINCT caja FROM ta_12_operaciones ORDER BY caja');
        return ["success" => true, "data" => [
            "tipo_aseo" => $tipoAseo,
            "recaudadoras" => $recaudadoras,
            "cajas" => $cajas
        ]];
    }
}
