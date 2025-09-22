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
                case 'mensaje.show':
                    // Show a message (simulate modal)
                    $validator = Validator::make($params, [
                        'imagen' => 'nullable|integer',
                        'mensaje' => 'required|string|max:1000',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'imagen' => $params['imagen'] ?? null,
                        'mensaje' => $params['mensaje']
                    ];
                    $eResponse['message'] = 'Mensaje mostrado correctamente.';
                    break;
                case 'mensaje.save':
                    // Save message to DB
                    $validator = Validator::make($params, [
                        'imagen' => 'nullable|integer',
                        'mensaje' => 'required|string|max:1000',
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_mensaje_save(?, ?)', [
                        $params['imagen'] ?? null,
                        $params['mensaje']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    $eResponse['message'] = 'Mensaje guardado correctamente.';
                    break;
                case 'mensaje.list':
                    // List all messages
                    $result = DB::select('SELECT * FROM sp_mensaje_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Mensajes listados correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado.';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
