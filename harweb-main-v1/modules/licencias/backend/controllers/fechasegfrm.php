<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
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
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest) {
                case 'fechasegfrm.save':
                    $validator = Validator::make($params, [
                        'fecha' => 'required|date',
                        'oficio' => 'required|string|max:255',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM fechasegfrm_save(:fecha, :oficio)', [
                        'fecha' => $params['fecha'],
                        'oficio' => $params['oficio'],
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Datos guardados correctamente.';
                    $eResponse['data'] = $result;
                    break;
                case 'fechasegfrm.list':
                    $result = DB::select('SELECT * FROM fechasegfrm_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado.';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
