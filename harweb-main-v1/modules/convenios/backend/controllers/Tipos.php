<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TiposController extends Controller
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
                case 'get_tipos':
                    $tipos = DB::select('SELECT * FROM ta_17_tipos ORDER BY tipo');
                    $response['success'] = true;
                    $response['data'] = $tipos;
                    break;
                case 'add_tipo':
                    $validator = Validator::make($payload, [
                        'tipo' => 'required|integer',
                        'descripcion' => 'required|string|max:50',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT sp_add_tipo(?, ?) as result', [
                        $payload['tipo'],
                        $payload['descripcion']
                    ]);
                    $response['success'] = $result[0]->result;
                    $response['message'] = $result[0]->result ? 'Tipo agregado correctamente' : 'Error al agregar tipo';
                    break;
                case 'update_tipo':
                    $validator = Validator::make($payload, [
                        'tipo' => 'required|integer',
                        'descripcion' => 'required|string|max:50',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT sp_update_tipo(?, ?) as result', [
                        $payload['tipo'],
                        $payload['descripcion']
                    ]);
                    $response['success'] = $result[0]->result;
                    $response['message'] = $result[0]->result ? 'Tipo actualizado correctamente' : 'Error al actualizar tipo';
                    break;
                case 'delete_tipo':
                    $validator = Validator::make($payload, [
                        'tipo' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT sp_delete_tipo(?) as result', [
                        $payload['tipo']
                    ]);
                    $response['success'] = $result[0]->result;
                    $response['message'] = $result[0]->result ? 'Tipo eliminado correctamente' : 'Error al eliminar tipo';
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
