<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        if (!$eRequest || !isset($eRequest['action'])) {
            $eResponse['message'] = 'Invalid request: missing action.';
            return response()->json(['eResponse' => $eResponse], 400);
        }

        try {
            switch ($eRequest['action']) {
                case 'save_observacion':
                    $validator = Validator::make($eRequest, [
                        'observacion' => 'required|string|max:2000',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        return response()->json(['eResponse' => $eResponse], 422);
                    }
                    $observacion = strtoupper($eRequest['observacion']);
                    $result = DB::select('SELECT * FROM sp_save_observacion(?)', [$observacion]);
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Observación guardada correctamente.';
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'get_observaciones':
                    $result = DB::select('SELECT * FROM sp_get_observaciones()');
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Observaciones obtenidas correctamente.';
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada: ' . $eRequest['action'];
                    return response()->json(['eResponse' => $eResponse], 400);
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = 'Error: ' . $ex->getMessage();
            return response()->json(['eResponse' => $eResponse], 500);
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
