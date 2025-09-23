<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute endpoint.
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
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_tipo_bloqueo_catalog':
                    $result = DB::select('SELECT * FROM get_tipo_bloqueo_catalog()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'bloquear_licencia':
                    $validator = Validator::make($params, [
                        'tipo_bloqueo_id' => 'required|integer',
                        'motivo' => 'required|string|max:255',
                        'usuario_id' => 'required|integer',
                        'licencia_id' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM bloquear_licencia(:tipo_bloqueo_id, :motivo, :usuario_id, :licencia_id)', [
                        'tipo_bloqueo_id' => $params['tipo_bloqueo_id'],
                        'motivo' => $params['motivo'],
                        'usuario_id' => $params['usuario_id'],
                        'licencia_id' => $params['licencia_id']
                    ]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                default:
                    $eResponse['message'] = 'eRequest not supported.';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
