<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaPagosTextoController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'preview_pagos_texto':
                    $response = $this->previewPagosTexto($payload);
                    break;
                case 'importar_pagos_texto':
                    $response = $this->importarPagosTexto($payload);
                    break;
                case 'resumen_importacion_pagos_texto':
                    $response = $this->resumenImportacionPagosTexto($payload);
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
     * Previsualiza el archivo de pagos en texto plano
     * @param array $payload
     * @return array
     */
    private function previewPagosTexto($payload)
    {
        // payload: { file_content: base64, filename: string }
        $fileContent = $payload['file_content'] ?? null;
        if (!$fileContent) {
            return [
                'success' => false,
                'message' => 'Archivo no recibido',
                'data' => null
            ];
        }
        $decoded = base64_decode($fileContent);
        $lines = preg_split('/\r?\n/', $decoded);
        $pagos = [];
        $row = 1;
        foreach ($lines as $line) {
            if (trim($line) === '') continue;
            $pagos[] = [
                'num_pago' => $row,
                'id_local' => substr($line, 0, 6),
                'axo' => substr($line, 6, 4),
                'periodo' => substr($line, 10, 2),
                'fecha_pago' => substr($line, 12, 2) . '/' . substr($line, 14, 2) . '/' . substr($line, 16, 4),
                'oficina_pago' => substr($line, 20, 3),
                'caja_pago' => substr($line, 23, 1),
                'operacion_pago' => substr($line, 24, 5),
                'importe_pago' => substr($line, 29, 9),
                'folio' => substr($line, 38, 6),
                'fecha_actualizacion' => substr($line, 44, 19),
                'id_usuario' => substr($line, 63, 3),
                'rec' => substr($line, 66, 3),
                'merc' => substr($line, 69, 3)
            ];
            $row++;
        }
        return [
            'success' => true,
            'message' => 'Archivo procesado',
            'data' => $pagos
        ];
    }

    /**
     * Importa los pagos desde el archivo de texto
     * @param array $payload
     * @return array
     */
    private function importarPagosTexto($payload)
    {
        // payload: { pagos: [ ... ] }
        $pagos = $payload['pagos'] ?? [];
        if (empty($pagos)) {
            return [
                'success' => false,
                'message' => 'No hay pagos para importar',
                'data' => null
            ];
        }
        $grabados = 0;
        $ya_grabados = 0;
        $borrados = 0;
        $importe_total = 0.0;
        DB::beginTransaction();
        try {
            foreach ($pagos as $pago) {
                $result = DB::select('SELECT * FROM sp_importar_pago_texto(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $pago['id_local'],
                    $pago['axo'],
                    $pago['periodo'],
                    $pago['fecha_pago'],
                    $pago['oficina_pago'],
                    $pago['caja_pago'],
                    $pago['operacion_pago'],
                    $pago['importe_pago'],
                    $pago['folio'],
                    $pago['fecha_actualizacion'],
                    $pago['id_usuario'],
                    $pago['rec'],
                    $pago['merc'],
                    auth()->id() ?? 0
                ]);
                $row = $result[0] ?? null;
                if ($row && $row->grabado) {
                    $grabados++;
                    $importe_total += floatval($pago['importe_pago']);
                } else {
                    $ya_grabados++;
                }
                if ($row && $row->adeudo_borrado) {
                    $borrados++;
                }
            }
            DB::commit();
            $total = $grabados + $ya_grabados;
            return [
                'success' => true,
                'message' => 'Importación completada',
                'data' => [
                    'grabados' => $grabados,
                    'ya_grabados' => $ya_grabados,
                    'borrados' => $borrados,
                    'total' => $total,
                    'importe_total' => $importe_total
                ]
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null
            ];
        }
    }

    /**
     * Devuelve resumen de importación (puede ser extendido)
     */
    private function resumenImportacionPagosTexto($payload)
    {
        // Implementar si se requiere
        return [
            'success' => true,
            'message' => 'Resumen no implementado',
            'data' => null
        ];
    }
}
