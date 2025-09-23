<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AspectoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getAspectos':
                    $result = DB::select('SELECT * FROM get_aspectos()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'setAspecto':
                    $aspecto = $params['aspecto'] ?? null;
                    if (!$aspecto) {
                        throw new \Exception('Aspecto requerido');
                    }
                    $result = DB::select('SELECT * FROM set_aspecto(?)', [$aspecto]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getCurrentAspecto':
                    $result = DB::select('SELECT * FROM get_current_aspecto()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            Log::error('AspectoController error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
