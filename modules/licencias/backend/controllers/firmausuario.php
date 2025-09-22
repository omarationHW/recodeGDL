<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FirmaUsuarioController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones relacionadas con firmausuario
     * Entrada: {
     *   "eRequest": {
     *     "action": "validate_firma_usuario",
     *     "data": {"usuario": "...", "firma": "..."}
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
        $eResponse = [];

        switch ($action) {
            case 'validate_firma_usuario':
                $validator = Validator::make($data, [
                    'usuario' => 'required|string',
                    'firma' => 'required|string',
                ]);
                if ($validator->fails()) {
                    $eResponse = [
                        'success' => false,
                        'errors' => $validator->errors(),
                    ];
                    break;
                }
                // Llamar al stored procedure para validar firma
                $result = DB::select('SELECT * FROM sp_validate_firma_usuario(?, ?)', [
                    $data['usuario'],
                    $data['firma']
                ]);
                if (isset($result[0]) && $result[0]->success) {
                    $eResponse = [
                        'success' => true,
                        'message' => $result[0]->message,
                        'usuario' => $data['usuario']
                    ];
                } else {
                    $eResponse = [
                        'success' => false,
                        'message' => $result[0]->message ?? 'Error de validación',
                    ];
                }
                break;
            default:
                $eResponse = [
                    'success' => false,
                    'message' => 'Acción no soportada',
                ];
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
