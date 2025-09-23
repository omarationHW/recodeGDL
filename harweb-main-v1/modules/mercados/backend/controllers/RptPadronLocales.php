<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RptPadronLocalesController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones vía eRequest/eResponse
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
                case 'getPadronLocales':
                    $response['data'] = $this->getPadronLocales($params);
                    $response['success'] = true;
                    break;
                case 'getRecaudadora':
                    $response['data'] = $this->getRecaudadora($params);
                    $response['success'] = true;
                    break;
                case 'getMercado':
                    $response['data'] = $this->getMercado($params);
                    $response['success'] = true;
                    break;
                case 'getRenta':
                    $response['data'] = $this->getRenta($params);
                    $response['success'] = true;
                    break;
                case 'getVencimientoRec':
                    $response['data'] = $this->getVencimientoRec($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error($e);
        }
        return response()->json($response);
    }

    /**
     * Obtiene el padrón de locales para una recaudadora y mercado
     */
    private function getPadronLocales($params)
    {
        $oficina = $params['oficina'] ?? null;
        $mercado = $params['mercado'] ?? null;
        if (!$oficina || !$mercado) {
            throw new \Exception('Parámetros requeridos: oficina, mercado');
        }
        $result = DB::select('CALL sp_get_padron_locales(?, ?)', [$oficina, $mercado]);
        return $result;
    }

    /**
     * Obtiene información de la recaudadora
     */
    private function getRecaudadora($params)
    {
        $oficina = $params['oficina'] ?? null;
        if (!$oficina) {
            throw new \Exception('Parámetro requerido: oficina');
        }
        $result = DB::select('CALL sp_get_recaudadora(?)', [$oficina]);
        return $result;
    }

    /**
     * Obtiene información del mercado
     */
    private function getMercado($params)
    {
        $oficina = $params['oficina'] ?? null;
        $mercado = $params['mercado'] ?? null;
        if (!$oficina || !$mercado) {
            throw new \Exception('Parámetros requeridos: oficina, mercado');
        }
        $result = DB::select('CALL sp_get_mercado(?, ?)', [$oficina, $mercado]);
        return $result;
    }

    /**
     * Obtiene la renta de un local
     */
    private function getRenta($params)
    {
        $axo = $params['axo'] ?? null;
        $categoria = $params['categoria'] ?? null;
        $seccion = $params['seccion'] ?? null;
        $clave_cuota = $params['clave_cuota'] ?? null;
        if (!$axo || !$categoria || !$seccion || !$clave_cuota) {
            throw new \Exception('Parámetros requeridos: axo, categoria, seccion, clave_cuota');
        }
        $result = DB::select('CALL sp_get_renta(?, ?, ?, ?)', [$axo, $categoria, $seccion, $clave_cuota]);
        return $result;
    }

    /**
     * Obtiene la fecha de vencimiento de recargos y descuentos
     */
    private function getVencimientoRec($params)
    {
        $mes = $params['mes'] ?? null;
        if (!$mes) {
            throw new \Exception('Parámetro requerido: mes');
        }
        $result = DB::select('CALL sp_get_vencimiento_rec(?)', [$mes]);
        return $result;
    }
}
