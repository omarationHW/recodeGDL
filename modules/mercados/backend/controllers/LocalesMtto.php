<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LocalesMttoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'get_catalogs':
                    $response['data'] = [
                        'recaudadoras' => DB::select('SELECT * FROM get_recaudadoras()'),
                        'secciones' => DB::select('SELECT * FROM get_secciones()'),
                        'zonas' => DB::select('SELECT * FROM get_zonas()'),
                        'cuotas' => DB::select('SELECT * FROM get_cuotas()')
                    ];
                    $response['success'] = true;
                    break;
                case 'buscar_local':
                    $result = DB::select('SELECT * FROM buscar_local(:oficina, :num_mercado, :categoria, :seccion, :local, :letra_local, :bloque)', [
                        'oficina' => $params['oficina'],
                        'num_mercado' => $params['num_mercado'],
                        'categoria' => $params['categoria'],
                        'seccion' => $params['seccion'],
                        'local' => $params['local'],
                        'letra_local' => $params['letra_local'],
                        'bloque' => $params['bloque']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'alta_local':
                    $validator = Validator::make($params, [
                        'oficina' => 'required|integer',
                        'num_mercado' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'local' => 'required|integer',
                        'nombre' => 'required|string',
                        'giro' => 'required|integer|min:1',
                        'sector' => 'required|string',
                        'superficie' => 'required|numeric|min:0.01',
                        'numero_memo' => 'required|integer|min:1',
                        'fecha_alta' => 'required|date',
                        'clave_cuota' => 'required|integer',
                        'zona' => 'required|integer',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM alta_local(
                        :oficina, :num_mercado, :categoria, :seccion, :local, :letra_local, :bloque, :nombre, :domicilio, :sector, :zona, :descripcion_local, :superficie, :giro, :fecha_alta, :clave_cuota, :id_usuario, :vigencia, :numero_memo, :axo
                    )', [
                        'oficina' => $params['oficina'],
                        'num_mercado' => $params['num_mercado'],
                        'categoria' => $params['categoria'],
                        'seccion' => $params['seccion'],
                        'local' => $params['local'],
                        'letra_local' => $params['letra_local'] ?? null,
                        'bloque' => $params['bloque'] ?? null,
                        'nombre' => $params['nombre'],
                        'domicilio' => $params['domicilio'] ?? '',
                        'sector' => $params['sector'],
                        'zona' => $params['zona'],
                        'descripcion_local' => $params['descripcion_local'] ?? '',
                        'superficie' => $params['superficie'],
                        'giro' => $params['giro'],
                        'fecha_alta' => $params['fecha_alta'],
                        'clave_cuota' => $params['clave_cuota'],
                        'id_usuario' => $params['id_usuario'],
                        'vigencia' => $params['vigencia'] ?? 'A',
                        'numero_memo' => $params['numero_memo'],
                        'axo' => $params['axo']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'get_locales':
                    $result = DB::select('SELECT * FROM get_locales(:oficina, :num_mercado, :categoria, :seccion, :local, :letra_local, :bloque)', [
                        'oficina' => $params['oficina'],
                        'num_mercado' => $params['num_mercado'],
                        'categoria' => $params['categoria'],
                        'seccion' => $params['seccion'],
                        'local' => $params['local'],
                        'letra_local' => $params['letra_local'],
                        'bloque' => $params['bloque']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
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
