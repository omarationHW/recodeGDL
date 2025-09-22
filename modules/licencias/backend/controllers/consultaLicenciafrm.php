<?php

namespace App\Http\Controllers\Licencias;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ConsultaLicenciaController extends Controller
{
    /**
     * Endpoint unificado para todas las operaciones del formulario consultaLicenciafrm
     * Entrada: {
     *   "eRequest": {
     *      "operation": "string", // e.g. 'search_by_licencia', 'search_by_ubicacion', etc.
     *      "params": { ... } // parámetros específicos
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $operation = $request->input('eRequest.operation');
        $params = $request->input('eRequest.params', []);
        $result = null;
        $error = null;

        try {
            switch ($operation) {
                case 'search_by_licencia':
                    $result = DB::select('SELECT * FROM licencias WHERE licencia = ?', [$params['licencia']]);
                    break;
                case 'search_by_ubicacion':
                    $result = DB::select('SELECT * FROM licencias WHERE ubicacion ILIKE ?', ["%{$params['ubicacion']}%"]);
                    break;
                case 'search_by_contribuyente':
                    $result = DB::select('SELECT * FROM licencias WHERE propietario ILIKE ?', ["%{$params['propietario']}%"]);
                    break;
                case 'search_by_tramite':
                    $result = DB::select('SELECT * FROM licencias WHERE id_licencia IN (SELECT id_licencia FROM tramites WHERE id_tramite = ?)', [$params['id_tramite']]);
                    break;
                case 'get_adeudos':
                    $result = DB::select('SELECT * FROM spget_lic_adeudos(?, ?)', [$params['id_licencia'], $params['tipo']]);
                    break;
                case 'get_pagos':
                    $result = DB::select('SELECT * FROM pagos WHERE cvecuenta = ? AND cveconcepto IN (8,27,28) AND cvecanc IS NULL ORDER BY fecha DESC', [$params['id_licencia']]);
                    break;
                case 'get_detalle_pago':
                    $result = DB::select('SELECT * FROM detsal_lic WHERE cvepago = ?', [$params['cvepago']]);
                    break;
                case 'bloquear_licencia':
                    $result = DB::select('SELECT * FROM sp_bloquear_licencia(?, ?, ?)', [$params['id_licencia'], $params['tipo_bloqueo'], $params['motivo']]);
                    break;
                case 'desbloquear_licencia':
                    $result = DB::select('SELECT * FROM sp_desbloquear_licencia(?, ?, ?)', [$params['id_licencia'], $params['tipo_bloqueo'], $params['motivo']]);
                    break;
                case 'exportar_excel':
                    // Implementar lógica de exportación (puede ser un job o respuesta directa)
                    $result = app('App\Services\LicenciasExportService')->export($params);
                    break;
                // ...otros casos según funcionalidades
                default:
                    $error = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }
}
