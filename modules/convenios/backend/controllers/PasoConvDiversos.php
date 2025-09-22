<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PasoConvDiversosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'import_file':
                    $response = $this->importFile($payload);
                    break;
                case 'process_rows':
                    $response = $this->processRows($payload);
                    break;
                case 'get_padron':
                    $response = $this->getPadron($payload);
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
     * Importa archivo y parsea filas (simulación, ya que el frontend parsea y manda JSON)
     */
    private function importFile($payload)
    {
        // El frontend debe parsear el archivo y enviar el array de filas
        return [
            'success' => true,
            'message' => 'Archivo importado correctamente',
            'data' => $payload['rows'] ?? []
        ];
    }

    /**
     * Procesa las filas y ejecuta la lógica de inserción/actualización
     */
    private function processRows($payload)
    {
        $rows = $payload['rows'] ?? [];
        $user_id = $payload['user_id'] ?? null;
        $errors = [];
        DB::beginTransaction();
        try {
            foreach ($rows as $i => $row) {
                // 1. Buscar en padron
                $padron = DB::selectOne('SELECT * FROM ta_17_con_reg_pred WHERE tipo = ? AND subtipo = ? AND manzana = ? AND lote = ? AND (letra = ? OR (letra IS NULL AND ? IS NULL))', [
                    $row['tipo'], $row['subtipo'], $row['manzana'], $row['lote'], $row['letra'], $row['letra']
                ]);
                if (!$padron) {
                    // Insertar en ta_17_con_reg_pred
                    $id_conv_predio = DB::selectOne('SELECT sp_insert_con_reg_pred(?,?,?,?,?,?,?,?) as id', [
                        $row['tipo'], $row['subtipo'], $row['manzana'], $row['lote'], $row['letra'], $user_id, $row['actualizacion'], $row['usuario']
                    ])->id;
                } else {
                    $id_conv_predio = $padron->id_conv_predio;
                }
                // Buscar en ta_17_conv_d_resto
                $resto = DB::selectOne('SELECT * FROM ta_17_conv_d_resto WHERE tipo = ? AND id_conv_diver = ?', [
                    $row['tipo'], $id_conv_predio
                ]);
                if (!$resto) {
                    // Insertar en ta_17_conv_d_resto
                    DB::select('SELECT sp_insert_conv_d_resto(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $row['tipo'], $id_conv_predio, null, $row['rec'], $row['zona'], $row['nombre'], $row['calle'], $row['exterior'], $row['interior'], $row['inciso'], $row['fecha_inicio'], $row['fecha_venc'], $row['pago_total'], $row['pago_inicio'], $row['pago_parcial'], $row['pago_final'], $row['total_pagos'], $row['metros'], $row['tipo_pago'], $row['observaciones'], $row['vigencia'], $row['usuario'], $row['actualizacion'], $user_id, $row['fecha_actual'], $row['letra'], $row['manzana'], $row['lote'], $row['subtipo']
                    ]);
                } else {
                    // Update
                    DB::select('SELECT sp_update_conv_d_resto(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $row['tipo'], $id_conv_predio, null, $row['rec'], $row['zona'], $row['nombre'], $row['calle'], $row['exterior'], $row['interior'], $row['inciso'], $row['fecha_inicio'], $row['fecha_venc'], $row['pago_total'], $row['pago_inicio'], $row['pago_parcial'], $row['pago_final'], $row['total_pagos'], $row['metros'], $row['tipo_pago'], $row['observaciones'], $row['vigencia'], $row['usuario'], $row['actualizacion'], $user_id, $row['fecha_actual'], $row['letra'], $row['manzana'], $row['lote'], $row['subtipo']
                    ]);
                }
            }
            DB::commit();
            return [
                'success' => true,
                'message' => 'Convenios procesados correctamente',
                'data' => null
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => $errors
            ];
        }
    }

    /**
     * Consulta padron por parámetros
     */
    private function getPadron($payload)
    {
        $tipo = $payload['tipo'];
        $subtipo = $payload['subtipo'];
        $manzana = $payload['manzana'];
        $lote = $payload['lote'];
        $letra = $payload['letra'];
        $padron = DB::selectOne('SELECT * FROM ta_17_con_reg_pred WHERE tipo = ? AND subtipo = ? AND manzana = ? AND lote = ? AND (letra = ? OR (letra IS NULL AND ? IS NULL))', [
            $tipo, $subtipo, $manzana, $lote, $letra, $letra
        ]);
        return [
            'success' => true,
            'message' => $padron ? 'Encontrado' : 'No encontrado',
            'data' => $padron
        ];
    }
}
