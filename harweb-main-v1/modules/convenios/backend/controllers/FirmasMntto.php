<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FirmasMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'firmas.list':
                    $response['data'] = DB::select('SELECT * FROM ta_17_firmaconv ORDER BY recaudadora');
                    $response['success'] = true;
                    break;
                case 'firmas.get':
                    $id = $params['recaudadora'] ?? null;
                    $response['data'] = DB::selectOne('SELECT * FROM ta_17_firmaconv WHERE recaudadora = ?', [$id]);
                    $response['success'] = true;
                    break;
                case 'firmas.create':
                    $validator = Validator::make($params, [
                        'recaudadora' => 'required|integer',
                        'titular' => 'required|string|max:100',
                        'cargotitular' => 'required|string|max:100',
                        'recaudador' => 'required|string|max:100',
                        'cargorecaudador' => 'required|string|max:100',
                        'testigo1' => 'required|string|max:100',
                        'testigo2' => 'required|string|max:100',
                        'letras' => 'required|string|max:3'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::statement('CALL sp_firmas_create(?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['recaudadora'],
                        $params['titular'],
                        $params['cargotitular'],
                        $params['recaudador'],
                        $params['cargorecaudador'],
                        $params['testigo1'],
                        $params['testigo2'],
                        $params['letras']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Registro creado correctamente.';
                    break;
                case 'firmas.update':
                    $validator = Validator::make($params, [
                        'recaudadora' => 'required|integer',
                        'titular' => 'required|string|max:100',
                        'cargotitular' => 'required|string|max:100',
                        'recaudador' => 'required|string|max:100',
                        'cargorecaudador' => 'required|string|max:100',
                        'testigo1' => 'required|string|max:100',
                        'testigo2' => 'required|string|max:100',
                        'letras' => 'required|string|max:3'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::statement('CALL sp_firmas_update(?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['recaudadora'],
                        $params['titular'],
                        $params['cargotitular'],
                        $params['recaudador'],
                        $params['cargorecaudador'],
                        $params['testigo1'],
                        $params['testigo2'],
                        $params['letras']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Registro actualizado correctamente.';
                    break;
                case 'firmas.delete':
                    $id = $params['recaudadora'] ?? null;
                    if (!$id) {
                        $response['message'] = 'ID requerido';
                        break;
                    }
                    $result = DB::statement('CALL sp_firmas_delete(?)', [$id]);
                    $response['success'] = true;
                    $response['message'] = 'Registro eliminado correctamente.';
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
