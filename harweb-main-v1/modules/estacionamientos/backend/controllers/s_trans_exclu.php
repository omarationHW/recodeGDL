<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $payload = $request->input('eRequest.payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'import_exclusivo_file':
                    $response = $this->importExclusivoFile($payload);
                    break;
                case 'insert_exclusivo_row':
                    $response = $this->insertExclusivoRow($payload);
                    break;
                case 'update_publicos_fecha_venci':
                    $response = $this->updatePublicosFechaVenci($payload);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Importar archivo plano y parsear registros (no inserta en DB, solo parsea)
     * payload: { file_content: string }
     */
    private function importExclusivoFile($payload)
    {
        if (!isset($payload['file_content'])) {
            return [
                'success' => false,
                'message' => 'No se recibió el contenido del archivo',
                'data' => null
            ];
        }
        $lines = preg_split('/\r?\n/', $payload['file_content']);
        $parsed = [];
        foreach ($lines as $line) {
            if (trim($line) === '') continue;
            $parsed[] = $this->parseExclusivoLine($line);
        }
        return [
            'success' => true,
            'message' => 'Archivo parseado correctamente',
            'data' => $parsed
        ];
    }

    /**
     * Insertar un registro en ta_18_exclusivo usando SP
     * payload: { ...campos... }
     */
    private function insertExclusivoRow($payload)
    {
        $validator = Validator::make($payload, [
            'CVE_SECTOR' => 'required|string|max:1',
            'CVE_ZONA' => 'required|string|max:1',
            'CVE_METROS' => 'required|integer',
            'CVE_TIPO' => 'required|string|max:1',
            'CVE_NUMERO' => 'required|integer',
            'NOMBRE' => 'required|string|max:30',
            'TELEFONO' => 'nullable|string|max:7',
            'CALLE' => 'nullable|string|max:30',
            'NUM' => 'nullable|string|max:4',
            'DOMFIS' => 'nullable|string|max:30',
            'FECHA_ALTA' => 'nullable|date',
            'FECHA_INIC' => 'nullable|date',
            'FECHA_VENCI' => 'nullable|date',
            'NUMOFT' => 'nullable|string|max:8',
            'NUMOFM' => 'nullable|string|max:4',
            'NUMCTAT' => 'nullable|integer',
            'ZOPPARQ' => 'nullable|integer',
            'MANZ' => 'nullable|integer',
            'ESTATUS' => 'nullable|string|max:1',
            'CLAVE' => 'nullable|string|max:1'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT sp_insert_ta_18_exclusivo(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) as inserted_id', [
            0, // control (auto, not used)
            $payload['CVE_SECTOR'],
            $payload['CVE_ZONA'],
            $payload['CVE_METROS'],
            $payload['CVE_TIPO'],
            $payload['CVE_NUMERO'],
            $payload['NOMBRE'],
            $payload['TELEFONO'] ?? '',
            $payload['CALLE'] ?? '',
            $payload['NUM'] ?? '',
            $payload['DOMFIS'] ?? '',
            $payload['FECHA_ALTA'] ?? null,
            $payload['FECHA_INIC'] ?? null,
            $payload['FECHA_VENCI'] ?? null,
            $payload['NUMOFT'] ?? '',
            $payload['NUMOFM'] ?? '',
            $payload['NUMCTAT'] ?? 0,
            $payload['ZOPPARQ'] ?? 0,
            $payload['MANZ'] ?? 0,
            $payload['ESTATUS'] ?? '',
            $payload['CLAVE'] ?? ''
        ]);
        return [
            'success' => true,
            'message' => 'Registro insertado correctamente',
            'data' => $result[0]->inserted_id ?? null
        ];
    }

    /**
     * Actualizar fecha de vencimiento en ta_15_publicos usando SP
     * payload: { fec_venci, sector, categ, num }
     */
    private function updatePublicosFechaVenci($payload)
    {
        $validator = Validator::make($payload, [
            'fec_venci' => 'required|date',
            'sector' => 'required|string',
            'categ' => 'required|string',
            'num' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT sp_update_ta_15_publicos_fecha_venci(?,?,?,?) as updated', [
            $payload['fec_venci'],
            $payload['sector'],
            $payload['categ'],
            $payload['num']
        ]);
        return [
            'success' => true,
            'message' => 'Fecha de vencimiento actualizada',
            'data' => $result[0]->updated ?? null
        ];
    }

    /**
     * Parsear una línea del archivo plano a array asociativo
     */
    private function parseExclusivoLine($line)
    {
        return [
            'CVE_SECTOR' => substr($line, 0, 1),
            'CVE_ZONA' => substr($line, 1, 1),
            'CVE_METROS' => intval(substr($line, 2, 3)),
            'CVE_TIPO' => substr($line, 5, 1),
            'CVE_NUMERO' => intval(substr($line, 6, 4)),
            'NOMBRE' => trim(substr($line, 10, 30)),
            'TELEFONO' => trim(substr($line, 40, 7)),
            'CALLE' => trim(substr($line, 47, 30)),
            'NUM' => trim(substr($line, 77, 4)),
            'DOMFIS' => trim(substr($line, 81, 30)),
            'FECHA_ALTA' => $this->parseDate(substr($line, 111, 6)),
            'FECHA_INIC' => $this->parseDate(substr($line, 117, 6)),
            'FECHA_VENCI' => $this->parseDate(substr($line, 123, 6)),
            'NUMOFT' => trim(substr($line, 129, 8)),
            'NUMOFM' => trim(substr($line, 137, 4)),
            'NUMCTAT' => intval(substr($line, 141, 4)),
            'ZOPPARQ' => intval(substr($line, 145, 2)),
            'MANZ' => intval(substr($line, 147, 2)),
            'ESTATUS' => substr($line, 149, 1),
            'CLAVE' => substr($line, 150, 1)
        ];
    }

    /**
     * Parsear fecha en formato ddmmyy a yyyy-mm-dd
     */
    private function parseDate($str)
    {
        $d = substr($str, 0, 2);
        $m = substr($str, 2, 2);
        $y = substr($str, 4, 2);
        if (!is_numeric($d) || !is_numeric($m) || !is_numeric($y)) return null;
        $year = intval($y) < 50 ? (2000 + intval($y)) : (1900 + intval($y));
        return sprintf('%04d-%02d-%02d', $year, intval($m), intval($d));
    }
}
