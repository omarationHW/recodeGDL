<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones vía eRequest/eResponse
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'eRequest' => 'required|array',
            'eRequest.action' => 'required|string',
            'eRequest.data' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'errors' => $validator->errors(),
                ]
            ], 422);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null,
            'errors' => null
        ];

        try {
            switch ($action) {
                case 'chgpass.validate_current':
                    // Valida la clave actual
                    $userId = auth()->id();
                    $currentPassword = $data['current_password'] ?? '';
                    $result = DB::select('SELECT * FROM sp_chgpass_validate_current(?, ?)', [$userId, $currentPassword]);
                    $response['success'] = $result[0]->is_valid;
                    $response['data'] = [ 'is_valid' => $result[0]->is_valid ];
                    $response['message'] = $result[0]->is_valid ? 'Clave actual válida.' : 'Clave actual incorrecta.';
                    break;
                case 'chgpass.change':
                    // Cambia la clave
                    $userId = auth()->id();
                    $currentPassword = $data['current_password'] ?? '';
                    $newPassword = $data['new_password'] ?? '';
                    $confirmPassword = $data['confirm_password'] ?? '';
                    $result = DB::select('SELECT * FROM sp_chgpass_change(?, ?, ?, ?)', [
                        $userId, $currentPassword, $newPassword, $confirmPassword
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
                    $response['errors'] = ['action' => 'Acción no soportada.'];
                    break;
            }
        } catch (\Exception $e) {
            $response['message'] = 'Error de servidor: ' . $e->getMessage();
            $response['errors'] = [$e->getMessage()];
        }

        return response()->json(['eResponse' => $response]);
    }
}
