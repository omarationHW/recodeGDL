<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PsplashController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario psplash
     * Entrada: {
     *   "eRequest": {
     *     "action": "get_version|get_splash_data",
     *     ...otros parámetros
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? null;
        $response = [];

        try {
            switch ($action) {
                case 'get_version':
                    $result = DB::select('SELECT * FROM psplash_get_version()');
                    $response = [
                        'version' => $result[0]->version ?? '1.0.0.0',
                        'app_name' => $result[0]->app_name ?? 'LICENCIAS',
                        'copyright' => $result[0]->copyright ?? '',
                        'company' => $result[0]->company ?? ''
                    ];
                    break;
                case 'get_splash_data':
                    $result = DB::select('SELECT * FROM psplash_get_splash_data()');
                    $response = [
                        'message' => $result[0]->message ?? 'Cargando Aplicación',
                        'label_effect' => $result[0]->label_effect ?? 'Padrón y Licencias',
                        'image_base64' => $result[0]->image_base64 ?? null
                    ];
                    break;
                default:
                    return response()->json([
                        'eResponse' => [
                            'error' => true,
                            'message' => 'Acción no soportada: ' . $action
                        ]
                    ], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $ex) {
            Log::error('PsplashController error: ' . $ex->getMessage());
            return response()->json([
                'eResponse' => [
                    'error' => true,
                    'message' => $ex->getMessage()
                ]
            ], 500);
        }
    }
}
