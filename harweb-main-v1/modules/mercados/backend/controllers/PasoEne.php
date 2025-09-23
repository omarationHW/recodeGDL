<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PasoEneController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones PasoEne
     * Entrada: eRequest con action, data
     * Salida: eResponse con status, data, errors
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'parse_txt':
                    $response = $this->parseTxt($data);
                    break;
                case 'bulk_insert':
                    $response = $this->bulkInsert($data);
                    break;
                case 'preview':
                    $response = $this->preview($data);
                    break;
                default:
                    $response['errors'][] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['errors'][] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Parsear archivo TXT de pagos de energía
     * Entrada: { file_content: string }
     * Salida: { status, data: [rows], errors }
     */
    private function parseTxt($data)
    {
        $rows = [];
        $lines = preg_split('/\r?\n/', $data['file_content'] ?? '');
        $i = 1;
        foreach ($lines as $line) {
            if (trim($line) === '') continue;
            $row = [
                'id_pago' => $i,
                'id_energia' => substr($line, 8, 6),
                'axo' => substr($line, 14, 5),
                'periodo' => substr($line, 19, 3),
                'fecha_pago' => substr($line, 29, 2) . '/' . substr($line, 27, 2) . '/' . substr($line, 23, 4),
                'oficina_pago' => substr($line, 31, 4),
                'caja_pago' => substr($line, 35, 1),
                'operacion_pago' => substr($line, 36, 6),
                'importe_pago' => substr($line, 42, 13),
                'consumo' => substr($line, 55, 1),
                'cantidad' => substr($line, 56, 9),
                'folio' => substr($line, 65, 10),
                'fecha_actualizacion' => (substr($line, 75, 4) == '0000') ? '2000' . substr($line, 79, 15) : substr($line, 75, 19),
                'id_usuario' => substr($line, 94, 3)
            ];
            $rows[] = $row;
            $i++;
        }
        return [
            'status' => 'ok',
            'data' => $rows,
            'errors' => []
        ];
    }

    /**
     * Insertar pagos de energía en lote
     * Entrada: { rows: [ {...} ] }
     * Salida: { status, data: {inserted, errors}, errors }
     */
    private function bulkInsert($data)
    {
        $rows = $data['rows'] ?? [];
        $inserted = 0;
        $errors = [];
        DB::beginTransaction();
        try {
            foreach ($rows as $idx => $row) {
                try {
                    DB::statement('CALL sp_pasoene_insert_pagoenergia(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $row['id_energia'],
                        $row['axo'],
                        $row['periodo'],
                        $row['fecha_pago'],
                        $row['oficina_pago'],
                        $row['caja_pago'],
                        $row['operacion_pago'],
                        $row['importe_pago'],
                        $row['consumo'],
                        $row['cantidad'],
                        $row['folio'],
                        $row['fecha_actualizacion'],
                        $row['id_usuario']
                    ]);
                    $inserted++;
                } catch (\Exception $e) {
                    $errors[] = 'Error en línea ' . ($idx+1) . ': ' . $e->getMessage();
                }
            }
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'status' => 'error',
                'data' => null,
                'errors' => [$e->getMessage()]
            ];
        }
        return [
            'status' => 'ok',
            'data' => [
                'inserted' => $inserted,
                'errors' => $errors
            ],
            'errors' => $errors
        ];
    }

    /**
     * Previsualizar pagos parseados (opcional)
     */
    private function preview($data)
    {
        // Puede ser igual a parseTxt
        return $this->parseTxt($data);
    }
}
