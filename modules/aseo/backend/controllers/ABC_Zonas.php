<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ZonasController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'status' => 'error',
            'message' => 'Acción no soportada',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'zonas.list':
                    $result = DB::select('SELECT * FROM ta_16_zonas ORDER BY ctrol_zona');
                    $response = [
                        'status' => 'success',
                        'message' => 'Listado de zonas',
                        'data' => $result
                    ];
                    break;
                case 'zonas.create':
                    $validator = Validator::make($payload, [
                        'zona' => 'required|integer',
                        'sub_zona' => 'required|integer',
                        'descripcion' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first(),
                            'data' => null
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_zonas_create(?, ?, ?)', [
                        $payload['zona'],
                        $payload['sub_zona'],
                        $payload['descripcion']
                    ]);
                    $response = [
                        'status' => 'success',
                        'message' => 'Zona creada',
                        'data' => $result
                    ];
                    break;
                case 'zonas.update':
                    $validator = Validator::make($payload, [
                        'ctrol_zona' => 'required|integer',
                        'zona' => 'required|integer',
                        'sub_zona' => 'required|integer',
                        'descripcion' => 'required|string|max:80'
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first(),
                            'data' => null
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_zonas_update(?, ?, ?, ?)', [
                        $payload['ctrol_zona'],
                        $payload['zona'],
                        $payload['sub_zona'],
                        $payload['descripcion']
                    ]);
                    $response = [
                        'status' => 'success',
                        'message' => 'Zona actualizada',
                        'data' => $result
                    ];
                    break;
                case 'zonas.delete':
                    $validator = Validator::make($payload, [
                        'ctrol_zona' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first(),
                            'data' => null
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_zonas_delete(?)', [
                        $payload['ctrol_zona']
                    ]);
                    $response = [
                        'status' => 'success',
                        'message' => 'Zona eliminada',
                        'data' => $result
                    ];
                    break;
                case 'zonas.get':
                    $validator = Validator::make($payload, [
                        'ctrol_zona' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first(),
                            'data' => null
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM ta_16_zonas WHERE ctrol_zona = ?', [
                        $payload['ctrol_zona']
                    ]);
                    $response = [
                        'status' => 'success',
                        'message' => 'Zona encontrada',
                        'data' => $result
                    ];
                    break;
                default:
                    $response = [
                        'status' => 'error',
                        'message' => 'Acción no soportada',
                        'data' => null
                    ];
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'message' => $e->getMessage(),
                'data' => null
            ];
        }
        return response()->json($response);
    }
}
