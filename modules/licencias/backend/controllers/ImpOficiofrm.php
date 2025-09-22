<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ImpOficioController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getOficioOptions':
                    $response['success'] = true;
                    $response['data'] = [
                        ['id' => 1, 'label' => 'Uno'],
                        ['id' => 2, 'label' => 'Dos'],
                        ['id' => 3, 'label' => 'M24BIS'],
                        ['id' => 4, 'label' => 'Informativo']
                    ];
                    break;
                case 'registerOficioDecision':
                    $validator = Validator::make($params, [
                        'tramite_id' => 'required|integer',
                        'oficio_type' => 'required|integer|in:1,2,3,4',
                        'usuario_id' => 'required|integer',
                        'observaciones' => 'nullable|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_imp_oficio_register(?, ?, ?, ?)', [
                        $params['tramite_id'],
                        $params['oficio_type'],
                        $params['usuario_id'],
                        $params['observaciones'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    $response['message'] = 'Decisión registrada correctamente.';
                    break;
                case 'getTramiteInfo':
                    $validator = Validator::make($params, [
                        'tramite_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $tramite = DB::select('SELECT * FROM sp_get_tramite_info(?)', [$params['tramite_id']]);
                    $response['success'] = true;
                    $response['data'] = $tramite;
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
