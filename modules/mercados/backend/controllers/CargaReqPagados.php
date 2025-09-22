<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class CargaReqPagadosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones relacionadas con CargaReqPagados
     * Entrada: eRequest con action, data, etc.
     * Salida: eResponse con status, data, errors
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $data = $eRequest['data'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'uploadFile':
                    $response = $this->uploadFile($data);
                    break;
                case 'parseFile':
                    $response = $this->parseFile($data);
                    break;
                case 'processPagos':
                    $response = $this->processPagos($data);
                    break;
                case 'getTotals':
                    $response = $this->getTotals($data);
                    break;
                default:
                    $response['errors'][] = 'Acción no reconocida';
            }
        } catch (\Exception $ex) {
            Log::error($ex->getMessage());
            $response['errors'][] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Subida de archivo (opcional, si se usa upload por API)
     */
    private function uploadFile($data)
    {
        // Aquí se puede manejar la subida de archivos si se requiere
        // Por simplicidad, se asume que el archivo ya está en el servidor
        return [
            'status' => 'ok',
            'data' => [
                'file_path' => $data['file_path'] ?? null
            ],
            'errors' => []
        ];
    }

    /**
     * Parsear archivo de pagos (texto plano)
     * Entrada: file_path
     * Salida: arreglo de registros parseados
     */
    private function parseFile($data)
    {
        $filePath = $data['file_path'] ?? null;
        if (!$filePath || !file_exists($filePath)) {
            return [
                'status' => 'error',
                'data' => null,
                'errors' => ['Archivo no encontrado']
            ];
        }
        $rows = [];
        $handle = fopen($filePath, 'r');
        $i = 1;
        while (($line = fgets($handle)) !== false) {
            $row = [
                'pagos' => $i,
                'id_local' => trim(substr($line, 0, 6)),
                'fecha_pago' => substr($line, 6, 2) . '/' . substr($line, 8, 2) . '/' . substr($line, 10, 4),
                'oficina' => trim(substr($line, 14, 3)),
                'caja' => trim(substr($line, 17, 1)),
                'operacion' => trim(substr($line, 18, 5)),
                'folio' => trim(substr($line, 23, 6)),
                'fecha_actualizacion' => trim(substr($line, 29, 19)),
                'usuario' => trim(substr($line, 48, 3)),
                'imp_multa' => trim(substr($line, 75, 9)),
                'imp_gastos' => trim(substr($line, 84, 9)),
                'folios_requerimientos' => trim(substr($line, 93, 150))
            ];
            $rows[] = $row;
            $i++;
        }
        fclose($handle);
        return [
            'status' => 'ok',
            'data' => $rows,
            'errors' => []
        ];
    }

    /**
     * Procesa los pagos cargados y actualiza la base de datos
     * Entrada: registros parseados
     * Salida: totales y resumen
     */
    private function processPagos($data)
    {
        $registros = $data['registros'] ?? [];
        $grabados = 0;
        $importeMulta = 0.0;
        $importeGastos = 0.0;
        DB::beginTransaction();
        try {
            foreach ($registros as $row) {
                $folios = array_filter(array_map('trim', explode(',', $row['folios_requerimientos'])));
                foreach ($folios as $folio) {
                    // Llama al stored procedure para actualizar el requerimiento
                    $result = DB::select('SELECT sp_carga_req_pagados(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $row['id_local'],
                        $folio,
                        $row['fecha_pago'],
                        $row['oficina'],
                        $row['caja'],
                        $row['operacion'],
                        $row['folio'],
                        $row['fecha_actualizacion'],
                        $row['usuario'],
                        $row['imp_multa'],
                        $row['imp_gastos'],
                        auth()->id() ?? 1
                    ]);
                    $grabados++;
                    $importeMulta += floatval($row['imp_multa']);
                    $importeGastos += floatval($row['imp_gastos']);
                }
            }
            DB::commit();
            return [
                'status' => 'ok',
                'data' => [
                    'grabados' => $grabados,
                    'total_pag' => count($registros),
                    'importe_multa' => $importeMulta,
                    'importe_gastos' => $importeGastos
                ],
                'errors' => []
            ];
        } catch (\Exception $ex) {
            DB::rollBack();
            return [
                'status' => 'error',
                'data' => null,
                'errors' => [$ex->getMessage()]
            ];
        }
    }

    /**
     * Obtiene los totales de la última carga
     */
    private function getTotals($data)
    {
        // Este método puede consultar una tabla de logs o devolver los últimos totales
        // Aquí se simula la respuesta
        return [
            'status' => 'ok',
            'data' => [
                'grabados' => $data['grabados'] ?? 0,
                'total_pag' => $data['total_pag'] ?? 0,
                'importe_multa' => $data['importe_multa'] ?? 0.0,
                'importe_gastos' => $data['importe_gastos'] ?? 0.0
            ],
            'errors' => []
        ];
    }
}
