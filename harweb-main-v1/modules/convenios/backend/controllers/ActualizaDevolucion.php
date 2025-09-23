<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ActualizaDevolucionController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $payload = $request->input('eRequest.payload');
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'uploadDevolucionFile':
                    $response = $this->uploadDevolucionFile($payload);
                    break;
                case 'previewDevolucionGrid':
                    $response = $this->previewDevolucionGrid($payload);
                    break;
                case 'processDevolucionGrid':
                    $response = $this->processDevolucionGrid($payload);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    /**
     * Carga archivo y lo parsea a grid (no inserta nada)
     */
    private function uploadDevolucionFile($payload)
    {
        // $payload['file'] es base64 o multipart
        $fileContent = $payload['file_content'] ?? null;
        if (!$fileContent) {
            return [
                'success' => false,
                'message' => 'Archivo no recibido',
                'data' => null
            ];
        }
        $lines = explode("\n", base64_decode($fileContent));
        $grid = [];
        foreach ($lines as $i => $line) {
            if (trim($line) === '') continue;
            $cols = explode('|', trim($line));
            $grid[] = $cols;
        }
        return [
            'success' => true,
            'message' => 'Archivo procesado',
            'data' => $grid
        ];
    }

    /**
     * Previsualiza el grid de devoluciones (sin grabar)
     */
    private function previewDevolucionGrid($payload)
    {
        // $payload['grid'] es array de arrays
        $grid = $payload['grid'] ?? [];
        // Opcional: Validar estructura
        return [
            'success' => true,
            'message' => 'Previsualización generada',
            'data' => $grid
        ];
    }

    /**
     * Procesa e inserta devoluciones en la base de datos
     */
    private function processDevolucionGrid($payload)
    {
        $grid = $payload['grid'] ?? [];
        $userId = $payload['user_id'] ?? null;
        $errores = [];
        $insertados = 0;
        DB::beginTransaction();
        try {
            foreach ($grid as $i => $row) {
                // Espera: [TODO, SERIAL, REMESA, OFICIO, FOLIO, FECHA_SOL, COL, CAL, FOL, IMPORTE, RFC, OBSERVACION, EJERCICIO, PROC, CRBO]
                if ($i === 0) continue; // Saltar encabezado
                if (count($row) < 15) {
                    $errores[] = "Fila $i: columnas insuficientes";
                    continue;
                }
                $col = trim($row[6]);
                $calle = trim($row[7]);
                $folio = trim($row[8]);
                // Buscar contrato
                $contrato = DB::table('ta_17_convenios')
                    ->where('colonia', $col)
                    ->where('calle', $calle)
                    ->where('folio', $folio)
                    ->first();
                if (!$contrato) {
                    $errores[] = "Fila $i: Contrato no encontrado (col: $col, calle: $calle, folio: $folio)";
                    continue;
                }
                // Insertar devolucion
                DB::statement('CALL sp_insert_devolucion(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $contrato->id_convenio,
                    $row[2], // remesa
                    $row[3], // oficio
                    $row[4], // folio
                    $row[5], // fecha_sol
                    $row[10], // rfc
                    $row[9], // importe
                    $row[11], // observacion
                    $row[12], // ejercicio
                    $row[13], // proc
                    $row[14], // crbo
                    $userId,
                    now(),
                    null, // id_devolucion (auto)
                    null  // fecha_actual (auto)
                ]);
                $insertados++;
            }
            DB::commit();
            return [
                'success' => true,
                'message' => "Devoluciones procesadas: $insertados, errores: " . count($errores),
                'data' => [
                    'insertados' => $insertados,
                    'errores' => $errores
                ]
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => $errores
            ];
        }
    }
}
