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
        $operation = $eRequest['operation'] ?? null;
        $data = $eRequest['data'] ?? [];
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($operation) {
                case 'check_rfc_exists':
                    $validator = Validator::make($data, [
                        'rfc' => 'required|string|max:13',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM check_rfc_exists(:rfc)', [
                        'rfc' => strtoupper(trim($data['rfc']))
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'exists' => $result && $result[0]->exists
                    ];
                    break;

                case 'insert_persona':
                    $validator = Validator::make($data, [
                        'nombre' => 'required|string|max:60',
                        'ap_pater' => 'nullable|string|max:15',
                        'ap_mater' => 'nullable|string|max:15',
                        'rfc' => 'required|string|max:13',
                        'ife' => 'nullable|string|max:15',
                        'sociedad' => 'required|in:F,M',
                        'usu_inicial' => 'required|integer',
                        'direccion' => 'nullable|string|max:255'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM insert_persona(:nombre, :ap_pater, :ap_mater, :rfc, :ife, :sociedad, :direccion, :usu_inicial)', [
                        'nombre' => strtoupper(trim($data['nombre'])),
                        'ap_pater' => strtoupper(trim($data['ap_pater'] ?? '')),
                        'ap_mater' => strtoupper(trim($data['ap_mater'] ?? '')),
                        'rfc' => strtoupper(trim($data['rfc'])),
                        'ife' => strtoupper(trim($data['ife'] ?? '')),
                        'sociedad' => $data['sociedad'],
                        'direccion' => $data['direccion'] ?? '',
                        'usu_inicial' => $data['usu_inicial']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['message'] = $result[0]->msg ?? 'Registro insertado correctamente.';
                    $eResponse['data'] = [
                        'id_esta_persona' => $result[0]->id_esta_persona
                    ];
                    break;

                default:
                    $eResponse['message'] = 'Operación no soportada.';
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
