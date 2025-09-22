<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class AccesoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario de acceso
     * Entrada: {
     *   "eRequest": {
     *     "action": "login|logout|getUser|setUserRegistry",
     *     "params": {...}
     *   }
     * }
     * Salida: {
     *   "eResponse": {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'login':
                    $response = $this->login($params);
                    break;
                case 'logout':
                    $response = $this->logout($params);
                    break;
                case 'getUser':
                    $response = $this->getUser($params);
                    break;
                case 'setUserRegistry':
                    $response = $this->setUserRegistry($params);
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no soportada", "data" => null];
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function login($params)
    {
        $validator = Validator::make($params, [
            'usuario' => 'required|string',
            'clave' => 'required|string',
            'ejercicio' => 'required|integer|min:2001'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $usuario = $params['usuario'];
        $clave = $params['clave'];
        $ejercicio = $params['ejercicio'];
        // Llama al stored procedure de validación
        $result = DB::select('SELECT * FROM sp_acceso_login(?, ?, ?)', [$usuario, $clave, $ejercicio]);
        if (count($result) > 0 && $result[0]->success) {
            // Opcional: guardar usuario en registro local (ver setUserRegistry)
            return ["success" => true, "message" => "Acceso concedido", "data" => $result[0]];
        } else {
            return ["success" => false, "message" => $result[0]->message ?? "Usuario o contraseña incorrectos", "data" => null];
        }
    }

    private function logout($params)
    {
        // Aquí podrías invalidar el token/jwt o limpiar sesión
        return ["success" => true, "message" => "Sesión cerrada", "data" => null];
    }

    private function getUser($params)
    {
        $usuario = $params['usuario'] ?? null;
        if (!$usuario) {
            return ["success" => false, "message" => "Usuario requerido", "data" => null];
        }
        $result = DB::select('SELECT * FROM sp_acceso_get_user(?)', [$usuario]);
        if (count($result) > 0) {
            return ["success" => true, "message" => "Usuario encontrado", "data" => $result[0]];
        } else {
            return ["success" => false, "message" => "Usuario no encontrado", "data" => null];
        }
    }

    private function setUserRegistry($params)
    {
        $usuario = $params['usuario'] ?? null;
        if (!$usuario) {
            return ["success" => false, "message" => "Usuario requerido", "data" => null];
        }
        // Simula guardar en registro local (en web sería en tabla de preferencias)
        DB::table('user_registry')->updateOrInsert([
            'key' => 'usuario_sistema'
        ], [
            'value' => $usuario,
            'updated_at' => now()
        ]);
        return ["success" => true, "message" => "Usuario guardado en registro", "data" => null];
    }
}
