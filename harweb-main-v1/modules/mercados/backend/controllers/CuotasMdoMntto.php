<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CuotasMdoMnttoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                    $response['data'] = DB::select('SELECT * FROM cuotasmdo_listar()');
                    $response['success'] = true;
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'axo' => 'required|integer|min:1992|max:2999',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'clave_cuota' => 'required|integer',
                        'importe' => 'required|numeric|min:0.01',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT cuotasmdo_insertar(?,?,?,?,?,?) as result', [
                        $data['axo'],
                        $data['categoria'],
                        $data['seccion'],
                        $data['clave_cuota'],
                        $data['importe'],
                        $data['id_usuario']
                    ]);
                    $response['success'] = $result[0]->result;
                    $response['message'] = $result[0]->result ? 'Registro creado correctamente' : 'Error al crear registro';
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'id_cuotas' => 'required|integer',
                        'axo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'clave_cuota' => 'required|integer',
                        'importe' => 'required|numeric|min:0.01',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT cuotasmdo_actualizar(?,?,?,?,?,?,?) as result', [
                        $data['id_cuotas'],
                        $data['axo'],
                        $data['categoria'],
                        $data['seccion'],
                        $data['clave_cuota'],
                        $data['importe'],
                        $data['id_usuario']
                    ]);
                    $response['success'] = $result[0]->result;
                    $response['message'] = $result[0]->result ? 'Registro actualizado correctamente' : 'Error al actualizar registro';
                    break;
                case 'delete':
                    $validator = Validator::make($data, [
                        'id_cuotas' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT cuotasmdo_eliminar(?) as result', [
                        $data['id_cuotas']
                    ]);
                    $response['success'] = $result[0]->result;
                    $response['message'] = $result[0]->result ? 'Registro eliminado correctamente' : 'Error al eliminar registro';
                    break;
                case 'catalogs':
                    $cats = DB::select('SELECT * FROM ta_11_categoria ORDER BY categoria');
                    $secs = DB::select('SELECT * FROM ta_11_secciones ORDER BY seccion');
                    $claves = DB::select('SELECT * FROM ta_11_cve_cuota ORDER BY clave_cuota');
                    $response['success'] = true;
                    $response['data'] = [
                        'categorias' => $cats,
                        'secciones' => $secs,
                        'claves' => $claves
                    ];
                    break;
                case 'get':
                    $validator = Validator::make($data, [
                        'id_cuotas' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM ta_11_cuo_locales WHERE id_cuotas = ?', [$data['id_cuotas']]);
                    $response['success'] = true;
                    $response['data'] = $result ? $result[0] : null;
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
