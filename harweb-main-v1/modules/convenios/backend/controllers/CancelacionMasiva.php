<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class CancelacionMasivaController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumiendo autenticación JWT

        switch ($action) {
            case 'cancelacion_masiva_listar':
                return $this->listarConveniosCancelados($params);
            case 'cancelacion_masiva_ejecutar':
                return $this->ejecutarCancelacionMasiva($params, $user);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Listar convenios cancelados hoy
     */
    public function listarConveniosCancelados($params)
    {
        $result = DB::select('SELECT * FROM sp_cancelacionmasiva_listar()');
        return response()->json([
            'success' => true,
            'message' => 'Convenios cancelados listados',
            'data' => $result
        ]);
    }

    /**
     * Ejecutar cancelación masiva de convenios
     * params: {
     *   vencidas: int (default 2),
     *   tipo: int (default 0)
     * }
     */
    public function ejecutarCancelacionMasiva($params, $user)
    {
        $validator = Validator::make($params, [
            'vencidas' => 'required|integer|min:1',
            'tipo' => 'nullable|integer',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }
        $tipo = $params['tipo'] ?? 0;
        $vencidas = $params['vencidas'];
        $fecha = date('Y-m-d');
        $iduser = $user ? $user->id : 0;
        $usuario = $user ? $user->username : 'sistema';

        $result = DB::select('SELECT * FROM sp_cancelacionmasiva_ejecutar(?, ?, ?, ?, ?)', [
            $tipo, $vencidas, $fecha, $iduser, $usuario
        ]);
        $row = $result[0] ?? null;
        return response()->json([
            'success' => $row && $row->estado == 0,
            'message' => $row ? $row->mensaje : 'Error en ejecución',
            'data' => $row
        ]);
    }
}
