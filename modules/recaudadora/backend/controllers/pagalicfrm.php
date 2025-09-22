<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'buscar_licencia':
                    $numero = (int)($params['numero'] ?? 0);
                    $axo = (int)($params['axo'] ?? 0);
                    $licencia = DB::selectOne('SELECT id_licencia as numero, ubicacion, numext_ubic, actividad FROM licencias WHERE licencia = ? AND vigente = ? LIMIT 1', [$numero, 'V']);
                    if (!$licencia) {
                        $response['message'] = 'NO existe este numero de licencia';
                        break;
                    }
                    $adeudos = DB::select('SELECT * FROM detsal_lic WHERE id_licencia = ? AND (id_anuncio = 0 OR id_anuncio IS NULL) AND (cvepago = 0 OR cvepago IS NULL) AND axo = ?', [$licencia->numero, $axo]);
                    if (empty($adeudos)) {
                        $response['message'] = 'NO existen adeudos para esta Licencia/Anuncio';
                        break;
                    }
                    $response['success'] = true;
                    $response['data'] = [
                        'licencia' => $licencia,
                        'adeudos' => $adeudos
                    ];
                    break;
                case 'buscar_anuncio':
                    $numero = (int)($params['numero'] ?? 0);
                    $axo = (int)($params['axo'] ?? 0);
                    $anuncio = DB::selectOne('SELECT id_anuncio as numero, ubicacion, numext_ubic, (medidas1::text || ' x ' || medidas2::text) as actividad FROM anuncios WHERE anuncio = ? AND vigente = ? LIMIT 1', [$numero, 'V']);
                    if (!$anuncio) {
                        $response['message'] = 'NO existe este numero de anuncio';
                        break;
                    }
                    $adeudos = DB::select('SELECT * FROM detsal_lic WHERE id_anuncio = ? AND (cvepago = 0 OR cvepago IS NULL) AND axo = ?', [$anuncio->numero, $axo]);
                    if (empty($adeudos)) {
                        $response['message'] = 'NO existen adeudos para esta Licencia/Anuncio';
                        break;
                    }
                    $response['success'] = true;
                    $response['data'] = [
                        'anuncio' => $anuncio,
                        'adeudos' => $adeudos
                    ];
                    break;
                case 'marcar_pagado':
                    $tipo = $params['tipo'] ?? 'licencia'; // 'licencia' o 'anuncio'
                    $numero = (int)($params['numero'] ?? 0);
                    $axo = (int)($params['axo'] ?? 0);
                    $user_id = (int)($params['user_id'] ?? 0); // opcional, para auditoría
                    if ($tipo === 'licencia') {
                        $licencia = DB::selectOne('SELECT id_licencia FROM licencias WHERE licencia = ? AND vigente = ? LIMIT 1', [$numero, 'V']);
                        if (!$licencia) {
                            $response['message'] = 'NO existe este numero de licencia';
                            break;
                        }
                        $id_licencia = $licencia->id_licencia;
                        // Marcar adeudos como pagados (cvepago = 999999999)
                        DB::beginTransaction();
                        DB::update('UPDATE detsal_lic SET cvepago = 999999999 WHERE id_licencia = ? AND (id_anuncio = 0 OR id_anuncio IS NULL) AND (cvepago = 0 OR cvepago IS NULL) AND axo = ?', [$id_licencia, $axo]);
                        // Ejecutar stored procedure para recalcular saldos
                        DB::statement('CALL calc_sdosl(?)', [$id_licencia]);
                        DB::commit();
                        $response['success'] = true;
                        $response['message'] = 'Licencia marcada como pagada correctamente.';
                    } else if ($tipo === 'anuncio') {
                        $anuncio = DB::selectOne('SELECT id_anuncio FROM anuncios WHERE anuncio = ? AND vigente = ? LIMIT 1', [$numero, 'V']);
                        if (!$anuncio) {
                            $response['message'] = 'NO existe este numero de anuncio';
                            break;
                        }
                        $id_anuncio = $anuncio->id_anuncio;
                        DB::beginTransaction();
                        DB::update('UPDATE detsal_lic SET cvepago = 999999999 WHERE id_anuncio = ? AND (cvepago = 0 OR cvepago IS NULL) AND axo = ?', [$id_anuncio, $axo]);
                        // Ejecutar stored procedure para recalcular saldos (si aplica)
                        DB::statement('CALL calc_sdosl_anuncio(?)', [$id_anuncio]);
                        DB::commit();
                        $response['success'] = true;
                        $response['message'] = 'Anuncio marcado como pagado correctamente.';
                    } else {
                        $response['message'] = 'Tipo no válido';
                    }
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            DB::rollBack();
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
