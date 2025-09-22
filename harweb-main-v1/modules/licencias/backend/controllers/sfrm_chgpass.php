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
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'validateCurrentPassword':
                    $eResponse = $this->validateCurrentPassword($eRequest);
                    break;
                case 'changePassword':
                    $eResponse = $this->changePassword($eRequest);
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json($eResponse);
    }

    /**
     * Valida la contraseña actual del usuario
     */
    private function validateCurrentPassword($eRequest)
    {
        $validator = Validator::make($eRequest, [
            'username' => 'required|string',
            'current_password' => 'required|string'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Datos incompletos',
                'data' => $validator->errors()
            ];
        }
        $result = DB::select('SELECT * FROM sp_validate_user_password(?, ?)', [
            $eRequest['username'],
            $eRequest['current_password']
        ]);
        if (!empty($result) && $result[0]->is_valid) {
            return [
                'success' => true,
                'message' => 'Contraseña válida',
                'data' => null
            ];
        } else {
            return [
                'success' => false,
                'message' => 'La contraseña actual no es correcta',
                'data' => null
            ];
        }
    }

    /**
     * Cambia la contraseña del usuario
     */
    private function changePassword($eRequest)
    {
        $validator = Validator::make($eRequest, [
            'username' => 'required|string',
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6|max:8',
            'confirm_password' => 'required|string|same:new_password'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Datos inválidos',
                'data' => $validator->errors()
            ];
        }
        // Lógica de validación adicional (números y letras, no igual a actual, etc)
        if (!preg_match('/^(?=.*[a-z])(?=.*\d)[a-z\d]{6,8}$/', $eRequest['new_password'])) {
            return [
                'success' => false,
                'message' => 'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres',
                'data' => null
            ];
        }
        if (substr($eRequest['current_password'], 0, 3) === substr($eRequest['new_password'], 0, 3)) {
            return [
                'success' => false,
                'message' => 'Los tres primeros caracteres deben ser diferentes a la clave actual',
                'data' => null
            ];
        }
        if ($eRequest['current_password'] === $eRequest['new_password']) {
            return [
                'success' => false,
                'message' => 'La nueva clave no debe ser igual a la actual',
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_change_user_password(?, ?, ?)', [
            $eRequest['username'],
            $eRequest['current_password'],
            $eRequest['new_password']
        ]);
        if (!empty($result) && $result[0]->success) {
            return [
                'success' => true,
                'message' => 'Clave cambiada exitosamente',
                'data' => null
            ];
        } else {
            return [
                'success' => false,
                'message' => $result[0]->message ?? 'No se pudo cambiar la clave',
                'data' => null
            ];
        }
    }
}
