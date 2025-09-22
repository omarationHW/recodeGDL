<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => '',
        ];

        try {
            switch ($eRequest) {
                case 'unit1_get_form_data':
                    // No data to fetch, just return success
                    $eResponse['success'] = true;
                    $eResponse['data'] = [];
                    $eResponse['message'] = 'Formulario Unit1 cargado correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = 'Error interno: ' . $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
