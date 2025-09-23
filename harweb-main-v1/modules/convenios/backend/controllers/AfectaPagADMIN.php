<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AfectaPagAdminController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario AfectaPagADMIN
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar|afectar|cancelar|licencias|predial",
     *     "fecha": "YYYY-MM-DD",
     *     ...otros parámetros según acción...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'listar':
                    $fecha = $input['fecha'] ?? null;
                    $result = DB::select('SELECT * FROM sp_afecta_pagadmin_listar(?)', [$fecha]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'afectar':
                    $fecha = $input['fecha'] ?? null;
                    $usuario = $input['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_afecta_pagadmin_afectar(?, ?)', [$fecha, $usuario]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'cancelar':
                    $id_pago = $input['id_pago'] ?? null;
                    $usuario = $input['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_afecta_pagadmin_cancelar(?, ?)', [$id_pago, $usuario]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'licencias':
                    $id_pago = $input['id_pago'] ?? null;
                    $usuario = $input['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_afecta_pagadmin_licencias(?, ?)', [$id_pago, $usuario]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'predial':
                    $id_pago = $input['id_pago'] ?? null;
                    $usuario = $input['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_afecta_pagadmin_predial(?, ?)', [$id_pago, $usuario]);
                    $response = ["success" => true, "data" => $result];
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no soportada", "data" => null];
            }
        } catch (\Exception $e) {
            Log::error('AfectaPagAdminController error: ' . $e->getMessage());
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }

        return response()->json(["eResponse" => $response]);
    }
}
