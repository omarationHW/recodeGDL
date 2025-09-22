<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AccesoController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'status' => 'error',
                'message' => 'Acción no reconocida',
                'data' => null
            ]
        ];

        switch ($action) {
            case 'login':
                $validator = Validator::make($params, [
                    'usuario' => 'required|string|max:50',
                    'contrasena' => 'required|string|max:50',
                ]);
                if ($validator->fails()) {
                    $response['eResponse']['message'] = 'Datos inválidos';
                    $response['eResponse']['errors'] = $validator->errors();
                    break;
                }
                $result = DB::select('SELECT * FROM sp_login_usuario(?, ?)', [
                    $params['usuario'],
                    $params['contrasena']
                ]);
                if (count($result) > 0 && $result[0]->autenticado) {
                    $response['eResponse'] = [
                        'status' => 'ok',
                        'message' => 'Acceso concedido',
                        'data' => [
                            'usuario' => $result[0]->usuario,
                            'nombre' => $result[0]->nombre,
                            'nivel' => $result[0]->nivel,
                            'id_usuario' => $result[0]->id_usuario
                        ]
                    ];
                } else {
                    $response['eResponse']['message'] = 'Usuario y/o contraseña incorrectos';
                }
                break;

            case 'logout':
                // Aquí podrías invalidar el token JWT si se usa
                $response['eResponse'] = [
                    'status' => 'ok',
                    'message' => 'Sesión cerrada',
                    'data' => null
                ];
                break;

            case 'getUserFromRegistry':
                // Simulación: en web no hay registry, se puede usar localStorage en frontend
                $response['eResponse'] = [
                    'status' => 'ok',
                    'message' => 'Usuario recuperado',
                    'data' => [
                        'usuario' => $params['usuario'] ?? ''
                    ]
                ];
                break;

            case 'setUserToRegistry':
                // Simulación: en web no hay registry, se puede usar localStorage en frontend
                $response['eResponse'] = [
                    'status' => 'ok',
                    'message' => 'Usuario guardado',
                    'data' => [
                        'usuario' => $params['usuario'] ?? ''
                    ]
                ];
                break;

            default:
                $response['eResponse']['message'] = 'Acción no soportada: ' . $action;
        }
        return response()->json($response);
    }
}
