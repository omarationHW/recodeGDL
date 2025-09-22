<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class MenuController extends Controller
{
    /**
     * Endpoint único para todas las operaciones del menú
     * Entrada: {
     *   "eRequest": {
     *     "operation": "string", // ejemplo: "login", "getMenu", "getEjercicios", etc
     *     "params": { ... } // parámetros específicos de la operación
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $operation = $input['operation'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["status" => "error", "message" => "Operación no válida"];

        try {
            switch ($operation) {
                case 'login':
                    $response = $this->login($params);
                    break;
                case 'getMenu':
                    $response = $this->getMenu($params);
                    break;
                case 'getEjercicios':
                    $response = $this->getEjercicios();
                    break;
                case 'checkVersion':
                    $response = $this->checkVersion($params);
                    break;
                case 'getUserInfo':
                    $response = $this->getUserInfo($params);
                    break;
                default:
                    $response = ["status" => "error", "message" => "Operación no soportada"];
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response = ["status" => "error", "message" => $e->getMessage()];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function login($params)
    {
        $usuario = $params['usuario'] ?? null;
        $password = $params['password'] ?? null;
        if (!$usuario || !$password) {
            return ["status" => "error", "message" => "Usuario y contraseña requeridos"];
        }
        $result = DB::select('SELECT * FROM sp_menu_login(?, ?)', [$usuario, $password]);
        if (count($result) > 0 && $result[0]->status === 'ok') {
            return ["status" => "ok", "user" => $result[0]];
        }
        return ["status" => "error", "message" => $result[0]->message ?? 'Acceso denegado'];
    }

    private function getMenu($params)
    {
        $usuario = $params['usuario'] ?? null;
        if (!$usuario) {
            return ["status" => "error", "message" => "Usuario requerido"];
        }
        $result = DB::select('SELECT * FROM sp_menu_get_menu(?)', [$usuario]);
        return ["status" => "ok", "menu" => $result];
    }

    private function getEjercicios()
    {
        $result = DB::select('SELECT * FROM sp_menu_get_ejercicios()');
        return ["status" => "ok", "ejercicios" => $result];
    }

    private function checkVersion($params)
    {
        $proyecto = $params['proyecto'] ?? null;
        $version = $params['version'] ?? null;
        if (!$proyecto || !$version) {
            return ["status" => "error", "message" => "Proyecto y versión requeridos"];
        }
        $result = DB::select('SELECT * FROM sp_menu_check_version(?, ?)', [$proyecto, $version]);
        return ["status" => "ok", "update_required" => $result[0]->update_required ?? false];
    }

    private function getUserInfo($params)
    {
        $usuario = $params['usuario'] ?? null;
        if (!$usuario) {
            return ["status" => "error", "message" => "Usuario requerido"];
        }
        $result = DB::select('SELECT * FROM sp_menu_get_user_info(?)', [$usuario]);
        if (count($result) > 0) {
            return ["status" => "ok", "user" => $result[0]];
        }
        return ["status" => "error", "message" => "Usuario no encontrado"];
    }
}
