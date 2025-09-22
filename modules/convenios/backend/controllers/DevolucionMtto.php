<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class DevolucionMttoController extends Controller
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
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list_devoluciones':
                    $response['data'] = DB::select('SELECT * FROM ta_17_devoluciones WHERE id_convenio = ?', [$payload['id_convenio']]);
                    $response['success'] = true;
                    break;
                case 'get_contrato':
                    $response['data'] = DB::selectOne('SELECT * FROM ta_17_convenios WHERE colonia = ? AND calle = ? AND folio = ? AND vigencia = \'A\'', [
                        $payload['colonia'], $payload['calle'], $payload['folio']
                    ]);
                    $response['success'] = true;
                    break;
                case 'get_pagos':
                    $result = DB::selectOne('SELECT COALESCE(SUM(importe),0) as pago FROM ta_17_pagos WHERE id_convenio = ?', [$payload['id_convenio']]);
                    $response['data'] = $result ? $result->pago : 0;
                    $response['success'] = true;
                    break;
                case 'create_devolucion':
                    $validator = Validator::make($payload, [
                        'id_convenio' => 'required|integer',
                        'remesa' => 'required|string|max:20',
                        'oficio' => 'required|string|max:20',
                        'folio' => 'required|string|max:15',
                        'fecha_solicitud' => 'required|date',
                        'rfc' => 'nullable|string|max:20',
                        'importe' => 'required|numeric',
                        'observacion' => 'nullable|string|max:60',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT sp_create_devolucion_mtto(?,?,?,?,?,?,?,?,?,?) as id', [
                        $payload['id_convenio'],
                        $payload['remesa'],
                        $payload['oficio'],
                        $payload['folio'],
                        $payload['fecha_solicitud'],
                        $payload['rfc'],
                        $payload['importe'],
                        $payload['observacion'],
                        $payload['id_usuario'],
                        now()
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0]->id ?? null;
                    break;
                case 'update_devolucion':
                    $validator = Validator::make($payload, [
                        'id_devolucion' => 'required|integer',
                        'remesa' => 'required|string|max:20',
                        'oficio' => 'required|string|max:20',
                        'folio' => 'required|string|max:15',
                        'fecha_solicitud' => 'required|date',
                        'rfc' => 'nullable|string|max:20',
                        'importe' => 'required|numeric',
                        'observacion' => 'nullable|string|max:60',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::statement('CALL sp_update_devolucion_mtto(?,?,?,?,?,?,?,?,?,?)', [
                        $payload['id_devolucion'],
                        $payload['remesa'],
                        $payload['oficio'],
                        $payload['folio'],
                        $payload['fecha_solicitud'],
                        $payload['rfc'],
                        $payload['importe'],
                        $payload['observacion'],
                        $payload['id_usuario'],
                        now()
                    ]);
                    $response['success'] = true;
                    break;
                case 'delete_devolucion':
                    $validator = Validator::make($payload, [
                        'id_devolucion' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::statement('CALL sp_delete_devolucion_mtto(?)', [
                        $payload['id_devolucion']
                    ]);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acci\u00f3n no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
