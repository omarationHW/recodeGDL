<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ActualizaFechaEmpresasController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'parse_file':
                    $response = $this->parseFile($params);
                    break;
                case 'get_empresa_info':
                    $response = $this->getEmpresaInfo($params);
                    break;
                case 'actualiza_fechas':
                    $response = $this->actualizaFechas($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Parsear archivo de texto plano con folios de empresas
     * params: { file_content: string }
     */
    private function parseFile($params)
    {
        $fileContent = $params['file_content'] ?? '';
        $rows = preg_split('/\r?\n/', $fileContent);
        $parsed = [];
        foreach ($rows as $i => $line) {
            if (trim($line) === '') continue;
            $fields = explode('|', $line);
            $parsed[] = [
                'id_pago' => $fields[0] ?? null,
                'folio' => $fields[1] ?? null,
                'cuenta_predial' => $fields[2] ?? null,
                'clave_cuenta' => $fields[3] ?? null,
                'anio_folio' => $fields[4] ?? null,
                'propietario' => $fields[5] ?? null,
                'importe_pagado' => $fields[6] ?? null,
                'notificacion' => $fields[7] ?? null,
                'fecha_pago' => $fields[8] ?? null,
                'estado' => $fields[9] ?? null
            ];
        }
        return [
            'success' => true,
            'message' => 'Archivo procesado',
            'data' => $parsed
        ];
    }

    /**
     * Obtener información de empresa por folio/cuenta
     * params: { clave_cuenta, folio, anio_folio }
     */
    private function getEmpresaInfo($params)
    {
        $claveCuenta = $params['clave_cuenta'] ?? null;
        $folio = $params['folio'] ?? null;
        $anio = $params['anio_folio'] ?? null;
        $empresa = DB::selectOne('SELECT e.nombre AS empresa FROM empresas e
            JOIN reqpredial r ON r.cvecuenta = e.cvecuenta
            WHERE r.folioreq = ? AND r.cvecuenta = ? AND r.axoreq = ? LIMIT 1',
            [$folio, $claveCuenta, $anio]);
        if ($empresa) {
            return [
                'success' => true,
                'message' => 'Empresa encontrada',
                'data' => $empresa
            ];
        } else {
            return [
                'success' => false,
                'message' => 'Empresa no encontrada',
                'data' => null
            ];
        }
    }

    /**
     * Actualizar fechas de práctica de folios de empresas
     * params: { folios: [ { clave_cuenta, folio, anio_folio, fecha_practica } ] }
     */
    private function actualizaFechas($params)
    {
        $folios = $params['folios'] ?? [];
        $aplicados = 0;
        $pendientes = 0;
        $errores = [];
        foreach ($folios as $folio) {
            $claveCuenta = $folio['clave_cuenta'] ?? null;
            $folioNum = $folio['folio'] ?? null;
            $anio = $folio['anio_folio'] ?? null;
            $fechaPractica = $folio['fecha_practica'] ?? null;
            $req = DB::selectOne('SELECT cvereq FROM reqpredial WHERE cvecuenta = ? AND folioreq = ? AND axoreq = ?',
                [$claveCuenta, $folioNum, $anio]);
            if ($req) {
                // Actualiza la fecha de práctica
                DB::statement('CALL sp_actualiza_fecha_practica(?, ?)', [$req->cvereq, $fechaPractica]);
                $aplicados++;
            } else {
                $pendientes++;
                $errores[] = [
                    'clave_cuenta' => $claveCuenta,
                    'folio' => $folioNum,
                    'anio_folio' => $anio,
                    'error' => 'Folio no encontrado'
                ];
            }
        }
        return [
            'success' => true,
            'message' => 'Actualización finalizada',
            'data' => [
                'aplicados' => $aplicados,
                'pendientes' => $pendientes,
                'errores' => $errores
            ]
        ];
    }
}
