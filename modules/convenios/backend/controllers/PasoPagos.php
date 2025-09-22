<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PasoPagosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones de PasoPagos
     * Entrada: {
     *   "eRequest": {
     *     "action": "openContrato|saveContrato|openConvenio|saveConvenio|statusDS",
     *     "payload": {...}
     *   }
     * }
     * Salida: {
     *   "eResponse": {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $payload = $input['payload'] ?? [];
        $response = [];

        try {
            switch ($action) {
                case 'openContrato':
                    $response = $this->openContrato($payload);
                    break;
                case 'saveContrato':
                    $response = $this->saveContrato($payload);
                    break;
                case 'openConvenio':
                    $response = $this->openConvenio($payload);
                    break;
                case 'saveConvenio':
                    $response = $this->saveConvenio($payload);
                    break;
                case 'statusDS':
                    $response = $this->statusDS($payload);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada',
                        'data' => null
                    ]]);
            }
        } catch (\Exception $e) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null
            ]]);
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Cargar archivo de pagos de contratos (AS/400)
     * payload: { "file": archivo base64, "filename": string }
     */
    private function openContrato($payload)
    {
        // Validar archivo
        if (empty($payload['file']) || empty($payload['filename'])) {
            return [
                'success' => false,
                'message' => 'Archivo no proporcionado',
                'data' => null
            ];
        }
        $lines = explode("\n", base64_decode($payload['file']));
        $data = [];
        $i = 1;
        foreach ($lines as $line) {
            if (trim($line) === '') continue;
            // Parsear campos según formato fijo (ajustar según layout real)
            $row = [
                'control' => $i,
                'colonia' => substr($line, 0, 4),
                'calle' => substr($line, 4, 4),
                'folio' => substr($line, 8, 6),
                'fecha' => substr($line, 21, 2) . '/' . substr($line, 19, 2) . '/' . substr($line, 14, 5),
                'oficina' => substr($line, 23, 4),
                'caja' => substr($line, 27, 1),
                'operacion' => substr($line, 28, 6),
                'pago_parcial' => substr($line, 35, 3),
                'total_parciales' => substr($line, 38, 3),
                'importe' => substr($line, 49, 10),
                'desc' => (substr($line, 41, 5) == '20' || substr($line, 41, 5) == '   20') ? substr($line, 41, 5) : null,
                'bonif' => null,
                'usuario' => $this->mapUsuario(substr($line, 68, 6)),
                'fecha_actual' => substr($line, 59, 5) . '-' . substr($line, 64, 2) . '-' . substr($line, 66, 2) . ' 12:00:00',
            ];
            $data[] = $row;
            $i++;
        }
        return [
            'success' => true,
            'message' => 'Archivo procesado',
            'data' => $data
        ];
    }

    /**
     * Guardar pagos de contratos en tabla temporal
     * payload: { "rows": [ {...} ] }
     */
    private function saveContrato($payload)
    {
        $rows = $payload['rows'] ?? [];
        DB::beginTransaction();
        try {
            DB::statement('CALL spd_17_b_p400cont()'); // Limpiar tabla temporal
            foreach ($rows as $row) {
                DB::insert('INSERT INTO ta_17_paso_p_400 (colonia, calle, folio, fecha, oficina, caja, operacion, pago_parcial, total_parciales, importe, desc, bonif, usuario, fecha_actual) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $row['colonia'], $row['calle'], $row['folio'], $row['fecha'], $row['oficina'], $row['caja'], $row['operacion'], $row['pago_parcial'], $row['total_parciales'], $row['importe'], $row['desc'], $row['bonif'], $row['usuario'], $row['fecha_actual']
                ]);
            }
            DB::commit();
            return [
                'success' => true,
                'message' => 'Pagos guardados correctamente',
                'data' => null
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
     * Cargar archivo de pagos de convenios generales
     * payload: { "file": archivo base64, "filename": string }
     */
    private function openConvenio($payload)
    {
        if (empty($payload['file']) || empty($payload['filename'])) {
            return [
                'success' => false,
                'message' => 'Archivo no proporcionado',
                'data' => null
            ];
        }
        $lines = explode("\n", base64_decode($payload['file']));
        $data = [];
        $i = 1;
        foreach ($lines as $line) {
            if (trim($line) === '') continue;
            // Parsear campos según formato fijo (ajustar según layout real)
            $row = [
                'control' => $i,
                'tipo' => substr($line, 0, 3),
                'subtipo' => '1',
                'manzana' => 'D66B' . substr($line, 6, 4),
                'lote' => substr($line, 14, 7),
                'letra' => (substr($line, 25, 1) == '0') ? null : ((substr($line, 25, 1) == '1') ? 'B' : 'S'),
                'fecha' => substr($line, 48, 2) . '/' . substr($line, 46, 2) . '/' . substr($line, 42, 4),
                'rec' => substr($line, 50, 4),
                'caja' => substr($line, 54, 1),
                'oper' => substr($line, 55, 6),
                'pag_parc' => substr($line, 26, 3),
                'tot_parc' => substr($line, 29, 3),
                'imp_pago' => substr($line, 61, 13),
                'desc' => null,
                'bonif' => null,
                'usuario' => '34',
                'actual' => substr($line, 76, 4) . '-' . substr($line, 80, 2) . '-' . substr($line, 82, 2) + ' 12:00:00',
                'imp_rec' => null,
                'cve_venc' => substr($line, 93, 1)
            ];
            $data[] = $row;
            $i++;
        }
        return [
            'success' => true,
            'message' => 'Archivo procesado',
            'data' => $data
        ];
    }

    /**
     * Guardar pagos de convenios generales
     * payload: { "rows": [ {...} ] }
     */
    private function saveConvenio($payload)
    {
        $rows = $payload['rows'] ?? [];
        DB::beginTransaction();
        try {
            foreach ($rows as $row) {
                // Buscar llave primaria
                $llave = DB::selectOne('SELECT * FROM ta_17_con_reg_pred WHERE tipo = ? AND subtipo = ? AND manzana = ? AND lote = ? AND (letra = ? OR (? IS NULL AND letra IS NULL))', [
                    $row['tipo'], $row['subtipo'], $row['manzana'], $row['lote'], $row['letra'], $row['letra']
                ]);
                if ($llave) {
                    $detalle = DB::selectOne('SELECT * FROM ta_17_conv_d_resto WHERE tipo = ? AND id_conv_diver = ?', [
                        $llave->tipo, $llave->id_conv_predio
                    ]);
                    if ($detalle) {
                        $pago = DB::selectOne('SELECT * FROM ta_17_conv_pagos WHERE id_conv_resto = ? AND pago_parcial = ?', [
                            $detalle->id_conv_resto, $row['pag_parc']
                        ]);
                        if (!$pago) {
                            DB::insert('INSERT INTO ta_17_conv_pagos (id_conv_pago, id_conv_resto, fecha_pago, oficina_pago, caja_pago, operacion_pago, pago_parcial, total_parciales, importe_pago, importe_recargo, cve_venc, cve_descuento, cve_bonificacion, id_usuario, fecha_actual) VALUES (DEFAULT, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                                $detalle->id_conv_resto, $row['fecha'], $row['rec'], $row['caja'], $row['oper'], $row['pag_parc'], $row['tot_parc'], $row['imp_pago'], $row['imp_rec'], $row['cve_venc'], $row['desc'], $row['bonif'], $row['usuario'], $row['actual']
                            ]);
                        }
                    }
                }
            }
            DB::commit();
            return [
                'success' => true,
                'message' => 'Pagos de convenios guardados correctamente',
                'data' => null
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
     * Consultar estatus de pagos DS
     * payload: { "id_usuario": int }
     */
    private function statusDS($payload)
    {
        $id_usuario = $payload['id_usuario'] ?? null;
        if (!$id_usuario) {
            return [
                'success' => false,
                'message' => 'id_usuario requerido',
                'data' => null
            ];
        }
        $result = DB::selectOne('SELECT * FROM spd_17_a_p400_cont(?)', [$id_usuario]);
        return [
            'success' => true,
            'message' => 'Consulta exitosa',
            'data' => $result
        ];
    }

    /**
     * Mapeo de usuario desde string a id
     */
    private function mapUsuario($str)
    {
        $map = [
            'apreci' => 15, 'CONVDI' => 15, 'CONSUL' => 15, 'ADRIAN' => 15, 'ILEANA' => 15, 'OPUBLI' => 15,
            'aramir' => 16,
            'bcabre' => 18, 'BENITA' => 18, 'BE' => 18,
            'ctsote' => 53,
            'mrosa' => 37,
            'fjmora' => 26, 'CONVPA' => 26, 'PACO' => 26,
            'jcerva' => 23, 'CONVLI' => 23, 'CONVAZ' => 23, 'CONVTE' => 23, 'LINO' => 23, 'CONVLU' => 23, 'OBRAS' => 23,
            'lgonza' => 24,
            'mileon' => 39,
            'sarand' => 2,
            'nrubio' => 27, 'CONVNO' => 27, 'NORA' => 27,
            'svalle' => 22, 'CONVSA' => 22,
            'CONVCR' => 28,
            'CONVMA' => 37,
            'CONVSO' => 3
        ];
        $str = strtolower(trim($str));
        return $map[$str] ?? null;
    }
}
