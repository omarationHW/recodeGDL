<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PrepagoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Prepago
     * Entrada: {
     *   "eRequest": {
     *     "action": "getPrepagoData|liquidacionParcial|getDescuentos|getUltimoRequerimiento|recalcularDPP|eliminarDPP|calcularDescuentoPredial",
     *     "params": { ... }
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
        $params = $input['params'] ?? [];
        $response = [];

        switch ($action) {
            case 'getPrepagoData':
                $response = $this->getPrepagoData($params);
                break;
            case 'liquidacionParcial':
                $response = $this->liquidacionParcial($params);
                break;
            case 'getDescuentos':
                $response = $this->getDescuentos($params);
                break;
            case 'getUltimoRequerimiento':
                $response = $this->getUltimoRequerimiento($params);
                break;
            case 'recalcularDPP':
                $response = $this->recalcularDPP($params);
                break;
            case 'eliminarDPP':
                $response = $this->eliminarDPP($params);
                break;
            case 'calcularDescuentoPredial':
                $response = $this->calcularDescuentoPredial($params);
                break;
            default:
                return response()->json(['eResponse' => [
                    'error' => 'Acción no soportada'
                ]], 400);
        }
        return response()->json(['eResponse' => $response]);
    }

    private function getPrepagoData($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return ['error' => 'cvecuenta es requerido'];
        }
        $data = DB::select('SELECT * FROM sp_prepago_get_data(?)', [$cvecuenta]);
        return $data[0] ?? [];
    }

    private function liquidacionParcial($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        $asalf = $params['asalf'] ?? null;
        $bsalf = $params['bsalf'] ?? null;
        if (!$cvecuenta || !$asalf || !$bsalf) {
            return ['error' => 'Parámetros insuficientes'];
        }
        $result = DB::select('SELECT * FROM sp_prepago_liquidacion_parcial(?,?,?)', [$cvecuenta, $asalf, $bsalf]);
        return $result[0] ?? [];
    }

    private function getDescuentos($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        $asal = $params['asal'] ?? 1900;
        $bsal = $params['bsal'] ?? 1;
        $asalf = $params['asalf'] ?? date('Y');
        $bsalf = $params['bsalf'] ?? 6;
        if (!$cvecuenta) {
            return ['error' => 'cvecuenta es requerido'];
        }
        $result = DB::select('SELECT * FROM sp_prepago_get_descuentos(?,?,?,?,?)', [$cvecuenta, $asal, $bsal, $asalf, $bsalf]);
        return $result;
    }

    private function getUltimoRequerimiento($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return ['error' => 'cvecuenta es requerido'];
        }
        $result = DB::select('SELECT * FROM sp_prepago_get_ultimo_requerimiento(?)', [$cvecuenta]);
        return $result[0] ?? [];
    }

    private function recalcularDPP($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return ['error' => 'cvecuenta es requerido'];
        }
        $result = DB::select('SELECT sp_prepago_recalcular_dpp(?) as status', [$cvecuenta]);
        return $result[0] ?? [];
    }

    private function eliminarDPP($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return ['error' => 'cvecuenta es requerido'];
        }
        $result = DB::select('SELECT sp_prepago_eliminar_dpp(?) as status', [$cvecuenta]);
        return $result[0] ?? [];
    }

    private function calcularDescuentoPredial($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return ['error' => 'cvecuenta es requerido'];
        }
        $result = DB::select('SELECT sp_prepago_calcular_descpred(?) as status', [$cvecuenta]);
        return $result[0] ?? [];
    }
}
