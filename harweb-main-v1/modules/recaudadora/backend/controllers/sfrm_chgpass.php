<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);

        switch ($eRequest) {
            case 'chgpass.validate_current':
                return $this->validateCurrentPassword($params);
            case 'chgpass.change_password':
                return $this->changePassword($params);
            default:
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Invalid eRequest',
                        'data' => null
                    ]
                ], 400);
        }
    }

    /**
     * Validate current password for user
     */
    private function validateCurrentPassword($params)
    {
        $validator = Validator::make($params, [
            'user_id' => 'required|integer',
            'current_password' => 'required|string|min:6|max:8',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 422);
        }

        $user = DB::table('users')->where('id', $params['user_id'])->first();
        if (!$user) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Usuario no encontrado',
                    'data' => null
                ]
            ], 404);
        }

        // Suponiendo que la contraseña está hasheada
        if (!Hash::check($params['current_password'], $user->password)) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'La clave actual no es correcta',
                    'data' => null
                ]
            ], 401);
        }

        return response()->json([
            'eResponse' => [
                'success' => true,
                'message' => 'Clave actual válida',
                'data' => null
            ]
        ]);
    }

    /**
     * Change password for user
     */
    private function changePassword($params)
    {
        $validator = Validator::make($params, [
            'user_id' => 'required|integer',
            'current_password' => 'required|string|min:6|max:8',
            'new_password' => 'required|string|min:6|max:8|different:current_password|regex:/^(?=.*[a-z])(?=.*\d)[a-z\d]{6,8}$/',
            'confirm_password' => 'required|string|same:new_password',
        ], [
            'new_password.regex' => 'La clave debe contener números y letras, y tener entre 6 y 8 caracteres.'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 422);
        }

        $user = DB::table('users')->where('id', $params['user_id'])->first();
        if (!$user) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Usuario no encontrado',
                    'data' => null
                ]
            ], 404);
        }

        if (!Hash::check($params['current_password'], $user->password)) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'La clave actual no es correcta',
                    'data' => null
                ]
            ], 401);
        }

        // Validar que los 3 primeros caracteres sean diferentes
        if (substr($params['current_password'], 0, 3) === substr($params['new_password'], 0, 3)) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Los tres primeros caracteres de la nueva clave deben ser diferentes a la actual',
                    'data' => null
                ]
            ], 422);
        }

        // Llamar stored procedure para cambiar la clave
        try {
            $result = DB::select('SELECT * FROM sp_chgpass_change_password(?, ?)', [
                $params['user_id'],
                Hash::make($params['new_password'])
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Error al cambiar la clave: ' . $e->getMessage(),
                    'data' => null
                ]
            ], 500);
        }

        return response()->json([
            'eResponse' => [
                'success' => true,
                'message' => 'Clave cambiada satisfactoriamente',
                'data' => null
            ]
        ]);
    }
}
