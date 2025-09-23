<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ChgPassController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'validateCurrentPassword':
                    $response = $this->validateCurrentPassword($params);
                    break;
                case 'changePassword':
                    $response = $this->changePassword($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Valida la clave actual del usuario
     */
    private function validateCurrentPassword($params)
    {
        $validator = Validator::make($params, [
            'user_id' => 'required|integer',
            'current_password' => 'required|string|min:6|max:8',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
            ];
        }
        $user = DB::table('usuarios')->where('id_usuario', $params['user_id'])->first();
        if (!$user) {
            return [
                'success' => false,
                'message' => 'Usuario no encontrado',
            ];
        }
        // Suponiendo que la contraseña está hasheada con bcrypt
        if (!password_verify($params['current_password'], $user->clave)) {
            return [
                'success' => false,
                'message' => 'La clave actual no es correcta',
            ];
        }
        return [
            'success' => true,
            'message' => 'Clave actual válida',
        ];
    }

    /**
     * Cambia la clave del usuario
     */
    private function changePassword($params)
    {
        $validator = Validator::make($params, [
            'user_id' => 'required|integer',
            'current_password' => 'required|string|min:6|max:8',
            'new_password' => 'required|string|min:6|max:8|different:current_password|regex:/^(?=.*[a-z])(?=.*\d)[a-z\d]{6,8}$/',
            'confirm_password' => 'required|string|same:new_password',
        ], [
            'new_password.regex' => 'La clave debe contener letras y números, y tener entre 6 y 8 caracteres.'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first(),
            ];
        }
        $user = DB::table('usuarios')->where('id_usuario', $params['user_id'])->first();
        if (!$user) {
            return [
                'success' => false,
                'message' => 'Usuario no encontrado',
            ];
        }
        if (!password_verify($params['current_password'], $user->clave)) {
            return [
                'success' => false,
                'message' => 'La clave actual no es correcta',
            ];
        }
        // Validación adicional: los 3 primeros caracteres deben ser diferentes
        if (substr($params['current_password'], 0, 3) === substr($params['new_password'], 0, 3)) {
            return [
                'success' => false,
                'message' => 'Los tres primeros caracteres de la nueva clave deben ser diferentes a la actual',
            ];
        }
        // Actualizar clave
        DB::table('usuarios')
            ->where('id_usuario', $params['user_id'])
            ->update(['clave' => bcrypt($params['new_password'])]);
        return [
            'success' => true,
            'message' => 'Clave cambiada satisfactoriamente',
        ];
    }
}
