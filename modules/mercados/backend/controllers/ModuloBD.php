<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ModuloBDController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $user = $request->user();
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getCategorias':
                    $response['data'] = DB::select('SELECT * FROM sp_get_categorias()');
                    $response['success'] = true;
                    break;
                case 'addCategoria':
                    $desc = $params['descripcion'] ?? '';
                    $response['data'] = DB::select('SELECT * FROM sp_add_categoria(?)', [$desc]);
                    $response['success'] = true;
                    break;
                case 'updateCategoria':
                    $id = $params['categoria'] ?? 0;
                    $desc = $params['descripcion'] ?? '';
                    $response['data'] = DB::select('SELECT * FROM sp_update_categoria(?, ?)', [$id, $desc]);
                    $response['success'] = true;
                    break;
                case 'getSecciones':
                    $response['data'] = DB::select('SELECT * FROM sp_get_secciones()');
                    $response['success'] = true;
                    break;
                case 'addSeccion':
                    $sec = $params['seccion'] ?? '';
                    $desc = $params['descripcion'] ?? '';
                    $response['data'] = DB::select('SELECT * FROM sp_add_seccion(?, ?)', [$sec, $desc]);
                    $response['success'] = true;
                    break;
                case 'updateSeccion':
                    $sec = $params['seccion'] ?? '';
                    $desc = $params['descripcion'] ?? '';
                    $response['data'] = DB::select('SELECT * FROM sp_update_seccion(?, ?)', [$sec, $desc]);
                    $response['success'] = true;
                    break;
                case 'getCveCuotas':
                    $response['data'] = DB::select('SELECT * FROM sp_get_cve_cuotas()');
                    $response['success'] = true;
                    break;
                case 'addCveCuota':
                    $clave = $params['clave_cuota'] ?? 0;
                    $desc = $params['descripcion'] ?? '';
                    $response['data'] = DB::select('SELECT * FROM sp_add_cve_cuota(?, ?)', [$clave, $desc]);
                    $response['success'] = true;
                    break;
                case 'updateCveCuota':
                    $clave = $params['clave_cuota'] ?? 0;
                    $desc = $params['descripcion'] ?? '';
                    $response['data'] = DB::select('SELECT * FROM sp_update_cve_cuota(?, ?)', [$clave, $desc]);
                    $response['success'] = true;
                    break;
                case 'getMercados':
                    $response['data'] = DB::select('SELECT * FROM sp_get_mercados()');
                    $response['success'] = true;
                    break;
                case 'addMercado':
                    $oficina = $params['oficina'] ?? 0;
                    $num_mercado_nvo = $params['num_mercado_nvo'] ?? 0;
                    $categoria = $params['categoria'] ?? 0;
                    $descripcion = $params['descripcion'] ?? '';
                    $cuenta_ingreso = $params['cuenta_ingreso'] ?? 0;
                    $cuenta_energia = $params['cuenta_energia'] ?? null;
                    $zona = $params['zona'] ?? 0;
                    $tipo_emision = $params['tipo_emision'] ?? 'M';
                    $response['data'] = DB::select('SELECT * FROM sp_add_mercado(?,?,?,?,?,?,?,?)', [
                        $oficina, $num_mercado_nvo, $categoria, $descripcion, $cuenta_ingreso, $cuenta_energia, $zona, $tipo_emision
                    ]);
                    $response['success'] = true;
                    break;
                case 'updateMercado':
                    $oficina = $params['oficina'] ?? 0;
                    $num_mercado_nvo = $params['num_mercado_nvo'] ?? 0;
                    $categoria = $params['categoria'] ?? 0;
                    $descripcion = $params['descripcion'] ?? '';
                    $cuenta_ingreso = $params['cuenta_ingreso'] ?? 0;
                    $cuenta_energia = $params['cuenta_energia'] ?? null;
                    $zona = $params['zona'] ?? 0;
                    $tipo_emision = $params['tipo_emision'] ?? 'M';
                    $response['data'] = DB::select('SELECT * FROM sp_update_mercado(?,?,?,?,?,?,?,?)', [
                        $oficina, $num_mercado_nvo, $categoria, $descripcion, $cuenta_ingreso, $cuenta_energia, $zona, $tipo_emision
                    ]);
                    $response['success'] = true;
                    break;
                // ... Agregar más acciones según el resto de los formularios ...
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error($e);
        }
        return response()->json($response);
    }
}
