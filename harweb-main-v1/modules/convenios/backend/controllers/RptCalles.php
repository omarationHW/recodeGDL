<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests.
     * Endpoint: /api/execute
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
                    'status' => 'error',
                    'message' => $validator->errors()->first(),
                    'data' => null
                ]
            ], 400);
        }

        $action = $request->input('eRequest.action');
        $data = $request->input('eRequest.data', []);

        try {
            switch ($action) {
                case 'RptCalles.getCallesByAxo':
                    $axo = isset($data['axo']) ? (int)$data['axo'] : null;
                    if (!$axo) {
                        return response()->json([
                            'eResponse' => [
                                'status' => 'error',
                                'message' => 'El parámetro axo es requerido.',
                                'data' => null
                            ]
                        ], 400);
                    }
                    $result = DB::select('SELECT * FROM rpt_calles_get_by_axo(?)', [$axo]);
                    return response()->json([
                        'eResponse' => [
                            'status' => 'success',
                            'message' => 'Datos obtenidos correctamente.',
                            'data' => $result
                        ]
                    ]);
                default:
                    return response()->json([
                        'eResponse' => [
                            'status' => 'error',
                            'message' => 'Acción no soportada: ' . $action,
                            'data' => null
                        ]
                    ], 400);
            }
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'status' => 'error',
                    'message' => $e->getMessage(),
                    'data' => null
                ]
            ], 500);
        }
    }
}
