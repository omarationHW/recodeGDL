<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class SdosFavorPagosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre SdosFavor_Pagos
     * Entrada: {
     *   "eRequest": {
     *     "action": "create|read|update|delete|list|find",
     *     "data": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $data = $eRequest['data'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'create':
                    $result = DB::select('SELECT * FROM sp_sdosfavor_pagos_create(?, ?, ?, ?, ?)', [
                        $data['reca'] ?? null,
                        $data['caja'] ?? null,
                        $data['folio'] ?? null,
                        $data['importe'] ?? null,
                        $data['fecha'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Pago creado correctamente';
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'read':
                    $result = DB::select('SELECT * FROM sp_sdosfavor_pagos_read(?, ?, ?)', [
                        $data['reca'] ?? null,
                        $data['caja'] ?? null,
                        $data['folio'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Pago localizado';
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'update':
                    $result = DB::select('SELECT * FROM sp_sdosfavor_pagos_update(?, ?, ?, ?, ?, ?)', [
                        $data['reca'] ?? null,
                        $data['caja'] ?? null,
                        $data['folio'] ?? null,
                        $data['importe'] ?? null,
                        $data['fecha'] ?? null,
                        $data['old_folio'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Pago actualizado correctamente';
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'delete':
                    $result = DB::select('SELECT * FROM sp_sdosfavor_pagos_delete(?, ?, ?)', [
                        $data['reca'] ?? null,
                        $data['caja'] ?? null,
                        $data['folio'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Pago eliminado correctamente';
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'list':
                    $result = DB::select('SELECT * FROM sp_sdosfavor_pagos_list()');
                    $response['success'] = true;
                    $response['message'] = 'Listado de pagos';
                    $response['data'] = $result;
                    break;
                case 'find':
                    $result = DB::select('SELECT * FROM sp_sdosfavor_pagos_find(?, ?, ?)', [
                        $data['reca'] ?? null,
                        $data['caja'] ?? null,
                        $data['folio'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Pago encontrado';
                    $response['data'] = $result[0] ?? null;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
