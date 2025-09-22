<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AutDesctoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descuentos predial
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o Sanctum
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'list':
                    $data = DB::select('SELECT * FROM sp_autdescto_list(:cvecuenta)', [
                        'cvecuenta' => $params['cvecuenta'] ?? null
                    ]);
                    $response = [
                        'status' => 'ok',
                        'data' => $data,
                        'message' => 'Listado de descuentos obtenidos'
                    ];
                    break;
                case 'create':
                    $validator = Validator::make($params, [
                        'cvecuenta' => 'required|integer',
                        'cvedescuento' => 'required|integer',
                        'bimini' => 'required|integer',
                        'bimfin' => 'required|integer',
                        'solicitante' => 'required|string',
                        'observaciones' => 'nullable|string',
                        'institucion' => 'nullable|integer',
                        'identificacion' => 'nullable|string',
                        'fecnac' => 'nullable|date',
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first()
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_autdescto_create(:cvecuenta, :cvedescuento, :bimini, :bimfin, :solicitante, :observaciones, :institucion, :identificacion, :fecnac, :usuario)', [
                        'cvecuenta' => $params['cvecuenta'],
                        'cvedescuento' => $params['cvedescuento'],
                        'bimini' => $params['bimini'],
                        'bimfin' => $params['bimfin'],
                        'solicitante' => $params['solicitante'],
                        'observaciones' => $params['observaciones'] ?? '',
                        'institucion' => $params['institucion'] ?? null,
                        'identificacion' => $params['identificacion'] ?? '',
                        'fecnac' => $params['fecnac'] ?? null,
                        'usuario' => $user->username ?? 'system',
                    ]);
                    $response = [
                        'status' => 'ok',
                        'data' => $result,
                        'message' => 'Descuento creado correctamente'
                    ];
                    break;
                case 'update':
                    $validator = Validator::make($params, [
                        'id' => 'required|integer',
                        'bimini' => 'required|integer',
                        'bimfin' => 'required|integer',
                        'solicitante' => 'required|string',
                        'observaciones' => 'nullable|string',
                        'institucion' => 'nullable|integer',
                        'identificacion' => 'nullable|string',
                        'fecnac' => 'nullable|date',
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first()
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_autdescto_update(:id, :bimini, :bimfin, :solicitante, :observaciones, :institucion, :identificacion, :fecnac, :usuario)', [
                        'id' => $params['id'],
                        'bimini' => $params['bimini'],
                        'bimfin' => $params['bimfin'],
                        'solicitante' => $params['solicitante'],
                        'observaciones' => $params['observaciones'] ?? '',
                        'institucion' => $params['institucion'] ?? null,
                        'identificacion' => $params['identificacion'] ?? '',
                        'fecnac' => $params['fecnac'] ?? null,
                        'usuario' => $user->username ?? 'system',
                    ]);
                    $response = [
                        'status' => 'ok',
                        'data' => $result,
                        'message' => 'Descuento actualizado correctamente'
                    ];
                    break;
                case 'cancel':
                    $validator = Validator::make($params, [
                        'id' => 'required|integer',
                        'motivo' => 'nullable|string',
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first()
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_autdescto_cancel(:id, :usuario, :motivo)', [
                        'id' => $params['id'],
                        'usuario' => $user->username ?? 'system',
                        'motivo' => $params['motivo'] ?? '',
                    ]);
                    $response = [
                        'status' => 'ok',
                        'data' => $result,
                        'message' => 'Descuento cancelado correctamente'
                    ];
                    break;
                case 'reactivate':
                    $validator = Validator::make($params, [
                        'id' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        return response()->json([
                            'status' => 'error',
                            'message' => $validator->errors()->first()
                        ], 422);
                    }
                    $result = DB::select('SELECT * FROM sp_autdescto_reactivate(:id, :usuario)', [
                        'id' => $params['id'],
                        'usuario' => $user->username ?? 'system',
                    ]);
                    $response = [
                        'status' => 'ok',
                        'data' => $result,
                        'message' => 'Descuento reactivado correctamente'
                    ];
                    break;
                case 'catalogs':
                    $descTypes = DB::select('SELECT * FROM c_descpred ORDER BY axodescto, descripcion');
                    $institutions = DB::select('SELECT * FROM c_instituciones ORDER BY institucion');
                    $response = [
                        'status' => 'ok',
                        'data' => [
                            'descTypes' => $descTypes,
                            'institutions' => $institutions
                        ],
                        'message' => 'Catálogos obtenidos'
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
