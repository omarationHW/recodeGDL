<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PasoContratosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'loadFilePreview':
                    $response = $this->loadFilePreview($payload);
                    break;
                case 'importPasoContratos':
                    $response = $this->importPasoContratos($payload);
                    break;
                case 'limpiarTablaPaso':
                    $response = $this->limpiarTablaPaso();
                    break;
                case 'getPasoContratosPreview':
                    $response = $this->getPasoContratosPreview();
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
     * Previsualiza el archivo cargado (sin guardar en BD)
     * @param array $payload
     * @return array
     */
    private function loadFilePreview($payload)
    {
        if (!isset($payload['file_content'])) {
            return [
                'success' => false,
                'message' => 'No se recibió archivo',
                'data' => null
            ];
        }
        $lines = explode("\n", $payload['file_content']);
        $preview = [];
        foreach ($lines as $idx => $line) {
            if (trim($line) === '') continue;
            $fields = explode('|', $line);
            $preview[] = $fields;
        }
        return [
            'success' => true,
            'message' => 'Archivo procesado',
            'data' => $preview
        ];
    }

    /**
     * Limpia la tabla de paso (llama SP)
     */
    private function limpiarTablaPaso()
    {
        DB::statement('CALL spd_17_limpia_paso()');
        return [
            'success' => true,
            'message' => 'Tabla de paso limpiada',
            'data' => null
        ];
    }

    /**
     * Importa los contratos desde el archivo cargado
     * @param array $payload
     * @return array
     */
    private function importPasoContratos($payload)
    {
        if (!isset($payload['file_content'])) {
            return [
                'success' => false,
                'message' => 'No se recibió archivo',
                'data' => null
            ];
        }
        // Limpia tabla de paso
        DB::statement('CALL spd_17_limpia_paso()');
        $lines = explode("\n", $payload['file_content']);
        $inserted = 0;
        $skipped = 0;
        foreach ($lines as $idx => $line) {
            if (trim($line) === '') continue;
            $fields = explode('|', $line);
            // Validación mínima: nombre y número de campos
            if (count($fields) < 38) {
                $skipped++;
                continue;
            }
            // Llama SP de inserción
            $result = DB::select('SELECT spd_17_insert_paso_contrato(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', $fields);
            $inserted++;
        }
        return [
            'success' => true,
            'message' => "Importación finalizada. Insertados: $inserted, Saltados: $skipped",
            'data' => [
                'inserted' => $inserted,
                'skipped' => $skipped
            ]
        ];
    }

    /**
     * Devuelve un preview de los datos cargados en la tabla de paso
     */
    private function getPasoContratosPreview()
    {
        $rows = DB::select('SELECT * FROM ta_17_paso_cont ORDER BY id ASC LIMIT 100');
        return [
            'success' => true,
            'message' => 'Preview de datos cargados',
            'data' => $rows
        ];
    }
}
