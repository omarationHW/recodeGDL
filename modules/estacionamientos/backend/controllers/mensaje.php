<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
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
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'show_message':
                    // Call stored procedure to log or process the message if needed
                    $tipo = $eRequest['params']['tipo'] ?? '';
                    $msg = $eRequest['params']['msg'] ?? '';
                    $icono = $eRequest['params']['icono'] ?? '';
                    // Optionally, you can log the message or store it in DB
                    $result = DB::select('SELECT * FROM sp_mensaje_show(:tipo, :msg, :icono)', [
                        'tipo' => $tipo,
                        'msg' => $msg,
                        'icono' => $icono
                    ]);
                    $response['success'] = true;
                    $response['data'] = [
                        'tipo' => $tipo,
                        'msg' => $msg,
                        'icono' => $icono
                    ]; // echo back for frontend
                    $response['message'] = 'Mensaje procesado correctamente.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $response['message'] = 'Error interno del servidor.';
        }

        return response()->json(['eResponse' => $response]);
    }
}
