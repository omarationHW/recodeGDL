<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class BusquedaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones de búsqueda catastral.
     * Entrada: eRequest con action y parámetros.
     * Salida: eResponse con datos o error.
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($action) {
                case 'buscar_por_nombre':
                    $validator = Validator::make($params, [
                        'nombre' => 'required|string|min:3'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception('Nombre requerido para búsqueda.');
                    }
                    $result = DB::select('CALL sp_busqueda_por_nombre(?)', [$params['nombre']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_por_ubicacion':
                    $validator = Validator::make($params, [
                        'calle' => 'required|string',
                        'exterior' => 'nullable|string'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception('Datos de ubicación incompletos.');
                    }
                    $result = DB::select('CALL sp_busqueda_por_ubicacion(?, ?)', [
                        $params['calle'],
                        $params['exterior'] ?? ''
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_por_clave_catastral':
                    $validator = Validator::make($params, [
                        'zona' => 'required|string',
                        'manzana' => 'required|string',
                        'predio' => 'nullable|string',
                        'subpredio' => 'nullable|string'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception('Datos de clave catastral incompletos.');
                    }
                    $result = DB::select('CALL sp_busqueda_por_clave_catastral(?, ?, ?, ?)', [
                        $params['zona'],
                        $params['manzana'],
                        $params['predio'] ?? '',
                        $params['subpredio'] ?? ''
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_por_rfc':
                    $validator = Validator::make($params, [
                        'rfc' => 'required|string|min:10'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception('RFC requerido para búsqueda.');
                    }
                    $result = DB::select('CALL sp_busqueda_por_rfc(?)', [$params['rfc']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_por_cuenta':
                    $validator = Validator::make($params, [
                        'recaud' => 'required|integer',
                        'urbrus' => 'required|string',
                        'cuenta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception('Datos de cuenta incompletos.');
                    }
                    $result = DB::select('CALL sp_busqueda_por_cuenta(?, ?, ?)', [
                        $params['recaud'],
                        $params['urbrus'],
                        $params['cuenta']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    throw new \Exception('Acción no soportada.');
            }
        } catch (\Exception $ex) {
            Log::error('BusquedaController error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
