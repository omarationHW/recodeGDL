<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['eRequest']['action'] ?? null;
        $params = $input['eRequest']['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'login':
                    $response = $this->login($params);
                    break;
                case 'logout':
                    $response = $this->logout();
                    break;
                case 'getUserInfo':
                    $response = $this->getUserInfo();
                    break;
                default:
                    $response['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['message'] = 'Error interno: ' . $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Login de usuario
     * @param array $params
     * @return array
     */
    private function login($params)
    {
        $validator = Validator::make($params, [
            'username' => 'required|string',
            'password' => 'required|string',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Datos incompletos',
                'errors' => $validator->errors()
            ];
        }
        $username = strtolower(trim($params['username']));
        $password = $params['password'];

        // Llama al stored procedure de autenticación
        $result = DB::select('SELECT * FROM sp_login_usuario(?, ?)', [$username, $password]);
        if (count($result) === 1 && $result[0]->success) {
            // Genera token JWT (ejemplo, puedes usar Passport/Sanctum)
            $user = $result[0];
            $token = base64_encode(json_encode([
                'user_id' => $user->id_usuario,
                'username' => $user->usuario,
                'nivel' => $user->nivel,
                'iat' => time(),
                'exp' => time() + 3600
            ]));
            return [
                'success' => true,
                'data' => [
                    'user' => $user,
                    'token' => $token
                ],
                'message' => 'Acceso correcto'
            ];
        } else {
            return [
                'success' => false,
                'message' => 'Usuario y/o contraseña incorrectos'
            ];
        }
    }

    /**
     * Logout (dummy, solo frontend borra token)
     */
    private function logout()
    {
        return [
            'success' => true,
            'message' => 'Sesión cerrada correctamente'
        ];
    }

    /**
     * Obtener información del usuario autenticado
     */
    private function getUserInfo()
    {
        // En producción, extraer user_id del token JWT
        // Aquí solo ejemplo
        return [
            'success' => true,
            'data' => [
                'user_id' => 1,
                'username' => 'admin',
                'nivel' => 1
            ],
            'message' => 'Usuario autenticado'
        ];
    }
}
