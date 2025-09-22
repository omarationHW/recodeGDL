<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $data = $eRequest['data'] ?? [];

        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($operation) {
                case 'firma_validate':
                    $validator = Validator::make($data, [
                        'firma_digital' => 'required|string|max:255',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = 'Firma digital requerida.';
                        $eResponse['errors'] = $validator->errors();
                        break;
                    }
                    // Call stored procedure to validate firma
                    $result = DB::select('SELECT * FROM sp_firma_validate(?)', [
                        $data['firma_digital']
                    ]);
                    if (isset($result[0]) && $result[0]->is_valid) {
                        $eResponse['success'] = true;
                        $eResponse['message'] = 'Firma válida.';
                        $eResponse['data'] = $result[0];
                    } else {
                        $eResponse['message'] = 'Firma inválida.';
                    }
                    break;
                case 'firma_save':
                    $validator = Validator::make($data, [
                        'firma_digital' => 'required|string|max:255',
                        'usuario_id' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = 'Datos requeridos faltantes.';
                        $eResponse['errors'] = $validator->errors();
                        break;
                    }
                    // Call stored procedure to save firma
                    $result = DB::select('SELECT * FROM sp_firma_save(?, ?)', [
                        $data['usuario_id'],
                        $data['firma_digital']
                    ]);
                    if (isset($result[0]) && $result[0]->success) {
                        $eResponse['success'] = true;
                        $eResponse['message'] = 'Firma guardada correctamente.';
                        $eResponse['data'] = $result[0];
                    } else {
                        $eResponse['message'] = $result[0]->message ?? 'Error al guardar la firma.';
                    }
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada.';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = 'Error interno: ' . $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
