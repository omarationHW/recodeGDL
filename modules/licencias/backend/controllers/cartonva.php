<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class CartonvaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con Cartografía Predial
     * Entrada: {
     *   "eRequest": {
     *     "action": "getCartografiaPredial",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [];

        try {
            switch ($action) {
                case 'getCartografiaPredial':
                    $eResponse = $this->getCartografiaPredial($params);
                    break;
                case 'getCuentaByCvecuenta':
                    $eResponse = $this->getCuentaByCvecuenta($params);
                    break;
                case 'getVisorUrl':
                    $eResponse = $this->getVisorUrl($params);
                    break;
                default:
                    return response()->json([
                        'eResponse' => [
                            'success' => false,
                            'message' => 'Acción no soportada',
                        ]
                    ], 400);
            }
        } catch (\Exception $ex) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $ex->getMessage(),
                ]
            ], 500);
        }

        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Obtiene la información de la cuenta catastral por cvecuenta
     * params: [ 'cvecuenta' => int ]
     */
    private function getCuentaByCvecuenta($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('Parámetro cvecuenta requerido');
        }
        $cuenta = DB::selectOne('SELECT * FROM convcta WHERE cvecuenta = ?', [$cvecuenta]);
        if (!$cuenta) {
            throw new \Exception('Cuenta no encontrada');
        }
        return [
            'success' => true,
            'data' => $cuenta
        ];
    }

    /**
     * Devuelve la URL del visor cartográfico para una cuenta catastral
     * params: [ 'cvecatnva' => string ]
     */
    private function getVisorUrl($params)
    {
        $cvecatnva = $params['cvecatnva'] ?? null;
        if (!$cvecatnva) {
            throw new \Exception('Parámetro cvecatnva requerido');
        }
        // URL base configurable
        $baseUrl = config('cartonva.visor_url', 'http://192.168.4.20:8080/Visor/index.html');
        $url = $baseUrl . '#user=123&session=se123&clavePredi0=' . urlencode($cvecatnva);
        return [
            'success' => true,
            'url' => $url
        ];
    }

    /**
     * Obtiene la información completa de la cartografía predial para una cuenta
     * params: [ 'cvecuenta' => int ]
     */
    private function getCartografiaPredial($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('Parámetro cvecuenta requerido');
        }
        $cuenta = DB::selectOne('SELECT * FROM convcta WHERE cvecuenta = ?', [$cvecuenta]);
        if (!$cuenta) {
            throw new \Exception('Cuenta no encontrada');
        }
        // URL del visor
        $visorUrl = $this->getVisorUrl(['cvecatnva' => $cuenta->cvecatnva]);
        return [
            'success' => true,
            'cuenta' => $cuenta,
            'visor_url' => $visorUrl['url']
        ];
    }
}
