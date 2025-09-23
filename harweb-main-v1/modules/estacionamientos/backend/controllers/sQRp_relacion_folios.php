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
            'errors' => []
        ];

        try {
            switch ($eRequest) {
                case 'sQRp_relacion_folios_report':
                    $validator = Validator::make($params, [
                        'opcion' => 'required|integer|in:1,2,3,4',
                        'fecha' => 'required|date',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['errors'] = $validator->errors();
                        $eResponse['message'] = 'Validation failed.';
                        return response()->json($eResponse, 422);
                    }
                    $opcion = $params['opcion'];
                    $fecha = $params['fecha'];
                    $result = DB::select('SELECT * FROM sQRp_relacion_folios_report(:opcion, :fecha)', [
                        'opcion' => $opcion,
                        'fecha' => $fecha
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Reporte generado correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado.';
                    return response()->json($eResponse, 400);
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage(), ['trace' => $ex->getTraceAsString()]);
            $eResponse['message'] = 'Error interno del servidor.';
            $eResponse['errors'] = [$ex->getMessage()];
            return response()->json($eResponse, 500);
        }
        return response()->json($eResponse);
    }
}
