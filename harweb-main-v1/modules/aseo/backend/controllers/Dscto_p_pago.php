<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class DsctoPPController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Dscto_p_pago
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|delete",
     *     "data": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? '';
        $data = $input['data'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM ta_16_dscto_pp ORDER BY fecha_inicio, fecha_fin');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'fecha_inicio' => 'required|date',
                        'fecha_fin' => 'required|date',
                        'porc_dscto' => 'required|numeric|min:0|max:100',
                        'usuario_mov' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $sp = "CALL sp_dscto_pp_create(?, ?, ?, ?)";
                    DB::statement($sp, [
                        $data['fecha_inicio'],
                        $data['fecha_fin'],
                        $data['porc_dscto'],
                        $data['usuario_mov']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Descuento por pronto pago creado correctamente';
                    break;
                case 'delete':
                    $validator = Validator::make($data, [
                        'id' => 'required|integer',
                        'usuario_mov' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $sp = "CALL sp_dscto_pp_delete(?, ?)";
                    DB::statement($sp, [
                        $data['id'],
                        $data['usuario_mov']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Descuento por pronto pago cancelado correctamente';
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
