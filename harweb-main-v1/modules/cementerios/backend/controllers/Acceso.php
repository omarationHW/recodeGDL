<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AccesoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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

        switch ($action) {
            case 'login':
                $response = $this->login($params);
                break;
            case 'getUserFromRegistry':
                $response = $this->getUserFromRegistry($params);
                break;
            case 'saveUserToRegistry':
                $response = $this->saveUserToRegistry($params);
                break;
            default:
                $response['message'] = 'Acción no soportada';
        }
        return response()->json($response);
    }

    /**
     * Login de usuario
     * params: ['usuario' => string, 'clave' => string]
     */
    private function login($params)
    {
        $validator = Validator::make($params, [
            'usuario' => 'required|string',
            'clave' => 'required|string',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Usuario y/o contraseña no pueden estar vacíos',
                'data' => null
            ];
        }
        $usuario = $params['usuario'];
        $clave = $params['clave'];
        try {
            $result = DB::select('SELECT * FROM sp_acceso_login(?, ?)', [$usuario, $clave]);
            if (count($result) === 1 && $result[0]->success) {
                return [
                    'success' => true,
                    'message' => 'Acceso correcto',
                    'data' => [
                        'usuario' => $result[0]->usuario,
                        'id_usuario' => $result[0]->id_usuario,
                        'nivel' => $result[0]->nivel,
                        'nombre' => $result[0]->nombre
                    ]
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Usuario y/o contraseña incorrectos',
                    'data' => null
                ];
            }
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Error de base de datos: ' . $e->getMessage(),
                'data' => null
            ];
        }
    }

    /**
     * Simula obtener usuario del registro de Windows (solo para compatibilidad)
     * params: []
     */
    private function getUserFromRegistry($params)
    {
        // En web, se puede guardar en localStorage del frontend
        return [
            'success' => true,
            'message' => '',
            'data' => null
        ];
    }

    /**
     * Simula guardar usuario en el registro de Windows (solo para compatibilidad)
     * params: ['usuario' => string]
     */
    private function saveUserToRegistry($params)
    {
        // En web, se puede guardar en localStorage del frontend
        return [
            'success' => true,
            'message' => '',
            'data' => null
        ];
    }
}
