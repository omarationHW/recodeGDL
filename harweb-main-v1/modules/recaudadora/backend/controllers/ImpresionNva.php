<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ImpresionNvaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones relacionadas con ImpresionNva
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getFormData':
                    // No data to fetch, just return success
                    $eResponse['success'] = true;
                    $eResponse['data'] = [];
                    $eResponse['message'] = 'Formulario cargado correctamente.';
                    break;
                case 'submitForm':
                    // No fields to process, just simulate success
                    $eResponse['success'] = true;
                    $eResponse['data'] = [];
                    $eResponse['message'] = 'Formulario enviado correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada.';
                    break;
            }
        } catch (\Exception $ex) {
            Log::error('ImpresionNvaController error: ' . $ex->getMessage());
            $eResponse['message'] = 'Error interno del servidor.';
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
