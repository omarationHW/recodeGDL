<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LicenciaMicrogeneradorEcologiaController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $user = $request->user() ? $request->user()->username : ($request->input('usuario') ?? 'anonimo');
        $anio = $data['anio'] ?? date('Y');
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'consulta':
                    $tipo = $data['tipo'] ?? null;
                    $id = $data['id'] ?? null;
                    if (!$tipo || !$id) {
                        throw new \Exception('Tipo y ID requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_licencia_microgenerador_ecologia(:p_opc, :p_id, :p_tipo, :p_anio, :p_usuario)', [
                        'p_opc' => 1,
                        'p_id' => $id,
                        'p_tipo' => $tipo,
                        'p_anio' => $anio,
                        'p_usuario' => $user
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'alta':
                    $tipo = $data['tipo'] ?? null;
                    $id = $data['id'] ?? null;
                    if (!$tipo || !$id) {
                        throw new \Exception('Tipo y ID requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_licencia_microgenerador_ecologia(:p_opc, :p_id, :p_tipo, :p_anio, :p_usuario)', [
                        'p_opc' => 2,
                        'p_id' => $id,
                        'p_tipo' => $tipo,
                        'p_anio' => $anio,
                        'p_usuario' => $user
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'cancela':
                    $tipo = $data['tipo'] ?? null;
                    $id = $data['id'] ?? null;
                    if (!$tipo || !$id) {
                        throw new \Exception('Tipo y ID requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_licencia_microgenerador_ecologia(:p_opc, :p_id, :p_tipo, :p_anio, :p_usuario)', [
                        'p_opc' => 3,
                        'p_id' => $id,
                        'p_tipo' => $tipo,
                        'p_anio' => $anio,
                        'p_usuario' => $user
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'tramite':
                    $tramite_id = $data['tramite_id'] ?? null;
                    if (!$tramite_id) {
                        throw new \Exception('ID de trámite requerido');
                    }
                    $tramite = DB::selectOne('SELECT id_tramite, folio, id_licencia, licencia_ref, nombre, ubicacion, actividad FROM vw_tramite_microgenerador WHERE id_tramite = :id', ['id' => $tramite_id]);
                    $response['success'] = true;
                    $response['data'] = $tramite;
                    break;
                case 'licencia':
                    $licencia = $data['licencia'] ?? null;
                    if (!$licencia) {
                        throw new \Exception('Licencia requerida');
                    }
                    $lic = DB::selectOne('SELECT id_licencia, licencia, nombre, ubicacion, actividad FROM vw_licencia_microgenerador WHERE licencia = :licencia', ['licencia' => $licencia]);
                    $response['success'] = true;
                    $response['data'] = $lic;
                    break;
                default:
                    throw new \Exception('Acción no soportada');
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
