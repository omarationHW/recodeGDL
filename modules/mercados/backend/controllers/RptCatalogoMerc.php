<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CatalogoMercadosController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'getCatalogoMercados':
                    $response['data'] = DB::select('CALL sp_get_catalogo_mercados()');
                    $response['success'] = true;
                    break;
                case 'createCatalogoMercado':
                    $result = DB::select('CALL sp_create_catalogo_mercado(?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado_nvo'],
                        $params['categoria'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['cuenta_energia'],
                        $params['id_zona'],
                        $params['tipo_emision'],
                        $params['usuario_id']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'updateCatalogoMercado':
                    $result = DB::select('CALL sp_update_catalogo_mercado(?,?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado_nvo'],
                        $params['categoria'],
                        $params['descripcion'],
                        $params['cuenta_ingreso'],
                        $params['cuenta_energia'],
                        $params['id_zona'],
                        $params['tipo_emision'],
                        $params['usuario_id']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'deleteCatalogoMercado':
                    $result = DB::select('CALL sp_delete_catalogo_mercado(?,?)', [
                        $params['oficina'],
                        $params['num_mercado_nvo']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getCatalogoMercadosReporte':
                    $response['data'] = DB::select('CALL sp_reporte_catalogo_mercados()');
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
