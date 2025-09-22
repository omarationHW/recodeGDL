<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BloqueoLicenciaController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de BloqueoLicencia
     * Entrada: {
     *   "eRequest": {
     *     "operation": "string", // e.g. 'search', 'block', 'unblock', 'list', 'history', 'update', 'report'
     *     ... otros parámetros según operación
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $operation = $input['operation'] ?? null;
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($operation) {
                case 'search':
                    $licencia = $input['licencia'] ?? null;
                    if (!$licencia) {
                        throw new \Exception('Número de licencia requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_search(?)', [$licencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'block':
                    $licencia = $input['licencia'] ?? null;
                    $motivo = $input['motivo'] ?? '';
                    $fecha_bloqueo = $input['fecha_bloqueo'] ?? null;
                    $usuario = $request->user()->username ?? 'sistema';
                    if (!$licencia || !$motivo || !$fecha_bloqueo) {
                        throw new \Exception('Datos incompletos para bloqueo');
                    }
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_block(?,?,?,?)', [$licencia, $motivo, $fecha_bloqueo, $usuario]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'unblock':
                    $licencia = $input['licencia'] ?? null;
                    $motivo = $input['motivo'] ?? '';
                    $fecha_desbloqueo = $input['fecha_desbloqueo'] ?? null;
                    $usuario = $request->user()->username ?? 'sistema';
                    if (!$licencia || !$motivo || !$fecha_desbloqueo) {
                        throw new \Exception('Datos incompletos para desbloqueo');
                    }
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_unblock(?,?,?,?)', [$licencia, $motivo, $fecha_desbloqueo, $usuario]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'list':
                    $status = $input['status'] ?? 'blocked'; // blocked|unblocked
                    $fecha = $input['fecha'] ?? null;
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_list(?,?)', [$status, $fecha]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'history':
                    $licencia = $input['licencia'] ?? null;
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_history(?)', [$licencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'update':
                    $licencia = $input['licencia'] ?? null;
                    $fecha_bloqueo = $input['fecha_bloqueo'] ?? null;
                    $motivo = $input['motivo'] ?? '';
                    $usuario = $request->user()->username ?? 'sistema';
                    if (!$licencia || !$fecha_bloqueo) {
                        throw new \Exception('Datos incompletos para actualización');
                    }
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_update(?,?,?,?)', [$licencia, $fecha_bloqueo, $motivo, $usuario]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'report':
                    $tipo = $input['tipo'] ?? 'blocked';
                    $fecha = $input['fecha'] ?? null;
                    $result = DB::select('SELECT * FROM sp_bloqueo_licencia_report(?,?)', [$tipo, $fecha]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    throw new \Exception('Operación no soportada');
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
