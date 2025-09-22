<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SubTipoMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('SELECT s.tipo, s.subtipo, s.desc_subtipo, s.cuenta_ingreso, s.id_usuario, s.fecha_actual, t.descripcion as tipo_desc FROM ta_17_subtipo_conv s JOIN ta_17_tipos t ON s.tipo = t.tipo ORDER BY s.tipo, s.subtipo');
                    $response['success'] = true;
                    break;
                case 'get':
                    $tipo = $data['tipo'] ?? null;
                    $subtipo = $data['subtipo'] ?? null;
                    $row = DB::selectOne('SELECT * FROM ta_17_subtipo_conv WHERE tipo = ? AND subtipo = ?', [$tipo, $subtipo]);
                    $response['data'] = $row;
                    $response['success'] = $row ? true : false;
                    $response['message'] = $row ? '' : 'No encontrado';
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'tipo' => 'required|integer',
                        'subtipo' => 'required|integer',
                        'desc_subtipo' => 'required|string|max:50',
                        'cuenta_ingreso' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_subtipo_conv_create(?,?,?,?,?)', [
                        $data['tipo'],
                        $data['subtipo'],
                        $data['desc_subtipo'],
                        $data['cuenta_ingreso'],
                        $data['id_usuario']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'tipo' => 'required|integer',
                        'subtipo' => 'required|integer',
                        'desc_subtipo' => 'required|string|max:50',
                        'cuenta_ingreso' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_subtipo_conv_update(?,?,?,?,?)', [
                        $data['tipo'],
                        $data['subtipo'],
                        $data['desc_subtipo'],
                        $data['cuenta_ingreso'],
                        $data['id_usuario']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'catalog_tipos':
                    $response['data'] = DB::select('SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo');
                    $response['success'] = true;
                    break;
                case 'catalog_cuentas':
                    $response['data'] = DB::select('SELECT cta_aplicacion, descripcion FROM ta_12_cuentas ORDER BY cta_aplicacion');
                    $response['success'] = true;
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
