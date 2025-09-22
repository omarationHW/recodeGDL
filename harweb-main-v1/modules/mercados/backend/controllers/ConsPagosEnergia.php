<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ConsPagosEnergiaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario ConsPagosEnergia
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|list|detail|export|...",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [];
        try {
            switch ($action) {
                case 'searchByLocal':
                    $response = $this->searchByLocal($params);
                    break;
                case 'searchByFechaPago':
                    $response = $this->searchByFechaPago($params);
                    break;
                case 'getRecaudadoras':
                    $response = $this->getRecaudadoras();
                    break;
                case 'getSecciones':
                    $response = $this->getSecciones();
                    break;
                case 'getCajasByOficina':
                    $response = $this->getCajasByOficina($params);
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }

    private function searchByLocal($params)
    {
        // Llama al stored procedure sp_cons_pagos_energia_local
        $result = DB::select('CALL sp_cons_pagos_energia_local(?,?,?,?,?,?,?,?)', [
            $params['oficina'] ?? 0,
            $params['num_mercado'] ?? 0,
            $params['categoria'] ?? 0,
            $params['seccion'] ?? '',
            $params['local'] ?? 0,
            $params['letra_local'] ?? null,
            $params['bloque'] ?? null,
            $params['orden'] ?? 'axo,periodo'
        ]);
        return ['data' => $result];
    }

    private function searchByFechaPago($params)
    {
        // Llama al stored procedure sp_cons_pagos_energia_fecha_pago
        $result = DB::select('CALL sp_cons_pagos_energia_fecha_pago(?,?,?,?,?,?,?)', [
            $params['fecha_pago'] ?? null,
            $params['oficina_pago'] ?? 0,
            $params['caja_pago'] ?? '',
            $params['operacion_pago'] ?? 0,
            $params['orden'] ?? 'fecha_pago,oficina_pago,caja_pago,operacion_pago',
            $params['limit'] ?? 1000,
            $params['offset'] ?? 0
        ]);
        return ['data' => $result];
    }

    private function getRecaudadoras()
    {
        $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return ['data' => $result];
    }

    private function getSecciones()
    {
        $result = DB::select('SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion');
        return ['data' => $result];
    }

    private function getCajasByOficina($params)
    {
        $result = DB::select('SELECT caja FROM ta_12_operaciones WHERE id_rec = ? ORDER BY caja', [
            $params['oficina'] ?? 0
        ]);
        return ['data' => $result];
    }
}
