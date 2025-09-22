<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ActualizaPlazoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload');
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'importFile':
                    $response = $this->importFile($payload);
                    break;
                case 'previewGrid':
                    $response = $this->previewGrid($payload);
                    break;
                case 'actualizarPlazo':
                    $response = $this->actualizarPlazo($payload);
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
     * Importa archivo y parsea líneas a arreglo
     */
    private function importFile($payload)
    {
        // $payload['file'] debe ser base64 o path temporal
        if (empty($payload['file'])) {
            return [
                'success' => false,
                'message' => 'Archivo no recibido',
                'data' => null
            ];
        }
        $lines = [];
        if (isset($payload['file_base64'])) {
            $content = base64_decode($payload['file_base64']);
            $lines = explode("\n", $content);
        } else if (isset($payload['file'])) {
            $lines = file($payload['file'], FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        }
        $parsed = [];
        foreach ($lines as $line) {
            $fields = explode('|', trim($line));
            $parsed[] = $fields;
        }
        return [
            'success' => true,
            'message' => 'Archivo importado',
            'data' => $parsed
        ];
    }

    /**
     * Previsualiza el grid de datos
     */
    private function previewGrid($payload)
    {
        // $payload['rows'] es un array de arrays (campos)
        $headers = [
            'TODO', 'SERIAL', 'OSC', 'EXPEDIENTE', 'FECHA ACT', 'COL', 'CAL', 'FOL',
            'SALDO', 'RECARGOS', 'TOTAL', 'PAGOS', 'INICIAL', 'CANTIDADP', 'FINAL',
            'INICIO', 'FIN', 'TIPO', 'OBSERVACIONES'
        ];
        $rows = $payload['rows'] ?? [];
        return [
            'success' => true,
            'message' => 'Previsualización generada',
            'data' => [
                'headers' => $headers,
                'rows' => $rows
            ]
        ];
    }

    /**
     * Ejecuta la actualización de plazo (inserta en ta_17_amp_plazo)
     */
    private function actualizarPlazo($payload)
    {
        $userId = $payload['user_id'] ?? null;
        $rows = $payload['rows'] ?? [];
        $errores = [];
        DB::beginTransaction();
        try {
            foreach ($rows as $i => $row) {
                // Validar campos mínimos
                if (count($row) < 19) {
                    $errores[] = "Fila ".($i+1).": columnas insuficientes";
                    continue;
                }
                // Llamar SP para calcular fecha de vencimiento
                $spResult = DB::select('SELECT * FROM spd_17_calc_fechav(?, ?, ?, ?, ?, ?)', [
                    (int)$row[5], // COL
                    (int)$row[6], // CAL
                    (int)$row[7], // FOL
                    $row[15],     // INICIO (fecha)
                    (int)$row[11],// PAGOS
                    $row[17]      // TIPO
                ]);
                if (empty($spResult)) {
                    $errores[] = "Fila ".($i+1).": error en cálculo de fecha de vencimiento";
                    continue;
                }
                $expression = $spResult[0]->expression;
                $fecha_venc = $spResult[0]->expression_1;
                // Insertar en ta_17_amp_plazo
                DB::insert('INSERT INTO ta_17_amp_plazo (
                    id_convenio, axo_oficio, folio_oficio, expediente, saldo, recargos, total, pago_inicial, pago_parcial, pagos, pago_final, tipo_pago, fecha_inicio, fecha_fin, observaciones, id_usuario, fecha_actual, fecha_act, fecha_vencimiento
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, now(), ?, ?)', [
                    $expression, // id_convenio
                    2005,        // axo_oficio (fijo)
                    $row[2],     // OSC
                    $row[3],     // EXPEDIENTE
                    $row[8],     // SALDO
                    $row[9],     // RECARGOS
                    $row[10],    // TOTAL
                    $row[12],    // INICIAL
                    $row[13],    // CANTIDADP
                    $row[11],    // PAGOS
                    $row[14],    // FINAL
                    $row[17],    // TIPO
                    $row[15],    // INICIO
                    $fecha_venc, // FIN (calculado)
                    $row[18],    // OBSERVACIONES
                    $userId,
                    $row[4].' 12:00:00', // FECHA ACT
                    $fecha_venc
                ]);
            }
            DB::commit();
            return [
                'success' => true,
                'message' => 'Actualización completada',
                'data' => [
                    'errores' => $errores
                ]
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => [
                    'errores' => $errores
                ]
            ];
        }
    }
}
