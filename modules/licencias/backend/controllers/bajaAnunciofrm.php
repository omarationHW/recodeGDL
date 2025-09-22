<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BajaAnuncioController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario de baja de anuncio.
     * Entrada: eRequest con action, params, user, etc.
     * Salida: eResponse con status, data, errors, etc.
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $user = $eRequest['user'] ?? null;
        $response = [
            'status' => 'error',
            'data' => null,
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'buscar_anuncio':
                    $validator = Validator::make($params, [
                        'anuncio' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_baja_anuncio_buscar(?)', [$params['anuncio']]);
                    $response['status'] = 'ok';
                    $response['data'] = $result;
                    break;
                case 'verificar_permisos':
                    $validator = Validator::make($params, [
                        'usuario' => 'required|string',
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_baja_anuncio_verificar_permisos(?)', [$params['usuario']]);
                    $response['status'] = 'ok';
                    $response['data'] = $result;
                    break;
                case 'baja_anuncio':
                    $validator = Validator::make($params, [
                        'anuncio' => 'required|integer',
                        'motivo' => 'nullable|string',
                        'axo_baja' => 'required|integer',
                        'folio_baja' => 'required|integer',
                        'usuario' => 'required|string',
                        'baja_error' => 'boolean',
                        'baja_tiempo' => 'boolean'
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_baja_anuncio_procesar(?,?,?,?,?,?,?,?)', [
                        $params['anuncio'],
                        $params['motivo'] ?? '',
                        $params['axo_baja'],
                        $params['folio_baja'],
                        $params['usuario'],
                        $params['baja_error'] ?? false,
                        $params['baja_tiempo'] ?? false,
                        now()
                    ]);
                    $response['status'] = 'ok';
                    $response['data'] = $result;
                    break;
                default:
                    $response['errors'][] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['errors'][] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
