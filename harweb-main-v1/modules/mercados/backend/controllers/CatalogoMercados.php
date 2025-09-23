<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CatalogoMercadosController extends Controller
{
    /**
     * Endpoint único para todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $payload = $input['payload'] ?? [];
        $user_id = $request->user()->id ?? null;
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('SELECT * FROM sp_catalogo_mercados_list()');
                    $response['success'] = true;
                    break;
                case 'create':
                    $validator = Validator::make($payload, [
                        'oficina' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'descripcion' => 'required|string',
                        'cuenta_ingreso' => 'required|integer',
                        'cuenta_energia' => 'nullable|integer',
                        'id_zona' => 'required|integer',
                        'tipo_emision' => 'required|string|max:1'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_catalogo_mercados_create(?,?,?,?,?,?,?,?)', [
                        $payload['oficina'],
                        $payload['num_mercado_nvo'],
                        $payload['categoria'],
                        $payload['descripcion'],
                        $payload['cuenta_ingreso'],
                        $payload['cuenta_energia'],
                        $payload['id_zona'],
                        $payload['tipo_emision']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'update':
                    $validator = Validator::make($payload, [
                        'oficina' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'descripcion' => 'required|string',
                        'cuenta_ingreso' => 'required|integer',
                        'cuenta_energia' => 'nullable|integer',
                        'id_zona' => 'required|integer',
                        'tipo_emision' => 'required|string|max:1'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_catalogo_mercados_update(?,?,?,?,?,?,?,?)', [
                        $payload['oficina'],
                        $payload['num_mercado_nvo'],
                        $payload['categoria'],
                        $payload['descripcion'],
                        $payload['cuenta_ingreso'],
                        $payload['cuenta_energia'],
                        $payload['id_zona'],
                        $payload['tipo_emision']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'delete':
                    $validator = Validator::make($payload, [
                        'oficina' => 'required|integer',
                        'num_mercado_nvo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_catalogo_mercados_delete(?,?)', [
                        $payload['oficina'],
                        $payload['num_mercado_nvo']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'report':
                    $oficina = $payload['oficina'] ?? null;
                    $result = DB::select('SELECT * FROM sp_catalogo_mercados_report(?)', [$oficina]);
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
