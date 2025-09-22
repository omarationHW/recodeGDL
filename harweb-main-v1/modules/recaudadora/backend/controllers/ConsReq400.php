<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

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
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($operation) {
                case 'getConsReq400':
                    // Validate params
                    $validator = validator($params, [
                        'ofnar' => 'required|string|max:8',
                        'tpr' => 'required|string|max:8',
                        'ctarfc' => 'required|string|max:8',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        return response()->json(['eResponse' => $eResponse], 422);
                    }
                    // Call stored procedure
                    $result = DB::select('SELECT * FROM sp_get_consreq400(:ofnar, :tpr, :ctarfc)', [
                        'ofnar' => $params['ofnar'],
                        'tpr' => $params['tpr'],
                        'ctarfc' => $params['ctarfc'],
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = count($result) > 0 ? 'Datos encontrados.' : 'No se localizaron requerimientos del AS400';
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada: ' . $operation;
                    return response()->json(['eResponse' => $eResponse], 400);
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
            return response()->json(['eResponse' => $eResponse], 500);
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
