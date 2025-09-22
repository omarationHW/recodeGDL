<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AdeudosContratosController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario AdeudosContratos
     * Entrada: {
     *   "eRequest": {
     *     "operation": "string", // listado, reporte, etc
     *     "params": { ... } // parámetros específicos
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? '';
        $params = $eRequest['params'] ?? [];
        $eResponse = [];

        try {
            switch ($operation) {
                case 'listado_todos':
                    $colonia = $params['colonia'] ?? null;
                    $calle = $params['calle'] ?? null;
                    $result = DB::select('CALL sp_adeudos_contratos_listado_todos(?, ?)', [$colonia, $calle]);
                    $eResponse['data'] = $result;
                    break;
                case 'listado_adeudos':
                    $colonia = $params['colonia'] ?? null;
                    $calle = $params['calle'] ?? null;
                    $result = DB::select('CALL sp_adeudos_contratos_listado_adeudos(?, ?)', [$colonia, $calle]);
                    $eResponse['data'] = $result;
                    break;
                case 'listado_saldos_favor':
                    $colonia = $params['colonia'] ?? null;
                    $calle = $params['calle'] ?? null;
                    $result = DB::select('CALL sp_adeudos_contratos_listado_saldos_favor(?, ?)', [$colonia, $calle]);
                    $eResponse['data'] = $result;
                    break;
                case 'listado_pagos_descuento':
                    $colonia = $params['colonia'] ?? null;
                    $result = DB::select('CALL sp_adeudos_contratos_listado_pagos_descuento(?)', [$colonia]);
                    $eResponse['data'] = $result;
                    break;
                case 'listado_liquidados_col_calle':
                    $colonia = $params['colonia'] ?? null;
                    $calle = $params['calle'] ?? null;
                    $result = DB::select('CALL sp_adeudos_contratos_listado_liquidados_col_calle(?, ?)', [$colonia, $calle]);
                    $eResponse['data'] = $result;
                    break;
                case 'listado_liquidados_col':
                    $colonia = $params['colonia'] ?? null;
                    $importe = $params['importe'] ?? null;
                    $result = DB::select('CALL sp_adeudos_contratos_listado_liquidados_col(?, ?)', [$colonia, $importe]);
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
