<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ManntoZonasController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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
                case 'ZONAS_LIST':
                    $response['data'] = DB::select('SELECT * FROM ta_16_zonas ORDER BY zona, sub_zona');
                    $response['success'] = true;
                    break;
                case 'ZONAS_GET':
                    $zona = $payload['zona'] ?? null;
                    $sub_zona = $payload['sub_zona'] ?? null;
                    $response['data'] = DB::select('SELECT * FROM ta_16_zonas WHERE zona = ? AND sub_zona = ?', [$zona, $sub_zona]);
                    $response['success'] = true;
                    break;
                case 'ZONAS_CREATE':
                    $validator = Validator::make($payload, [
                        'zona' => 'required|integer',
                        'sub_zona' => 'required|integer',
                        'descripcion' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_zonas_create(?, ?, ?)', [
                        $payload['zona'],
                        $payload['sub_zona'],
                        $payload['descripcion']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'ZONAS_UPDATE':
                    $validator = Validator::make($payload, [
                        'zona' => 'required|integer',
                        'sub_zona' => 'required|integer',
                        'descripcion' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_zonas_update(?, ?, ?)', [
                        $payload['zona'],
                        $payload['sub_zona'],
                        $payload['descripcion']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'ZONAS_DELETE':
                    $validator = Validator::make($payload, [
                        'ctrol_zona' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_zonas_delete(?)', [
                        $payload['ctrol_zona']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'ZONAS_EMPRESA_DEPENDENCY':
                    $ctrol_zona = $payload['ctrol_zona'] ?? null;
                    $empresas = DB::select('SELECT * FROM ta_16_empresas WHERE ctrol_zona = ?', [$ctrol_zona]);
                    $response['data'] = $empresas;
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
