<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];

        $eResponse = [
            'success' => false,
            'data' => null,
            'errors' => [],
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'validate_hasta_form':
                    $validator = Validator::make($params, [
                        'bimestre' => 'required|integer|min:1|max:6',
                        'anio' => 'required|integer|min:1970|max:' . date('Y'),
                    ], [
                        'bimestre.required' => 'El bimestre es obligatorio.',
                        'bimestre.integer' => 'El bimestre debe ser un número.',
                        'bimestre.min' => 'El bimestre solo puede ser de 1 a 6.',
                        'bimestre.max' => 'El bimestre solo puede ser de 1 a 6.',
                        'anio.required' => 'El año es obligatorio.',
                        'anio.integer' => 'El año debe ser un número.',
                        'anio.min' => 'El año no puede ser menor a 1970.',
                        'anio.max' => 'El año no puede ser mayor al año actual.'
                    ]);

                    if ($validator->fails()) {
                        $eResponse['errors'] = $validator->errors()->all();
                        $eResponse['message'] = 'Errores de validación.';
                        return response()->json(['eResponse' => $eResponse], 422);
                    }

                    // Opcional: Llamar SP para lógica adicional
                    $result = DB::select('SELECT * FROM sp_validate_hasta_form(?, ?)', [
                        $params['bimestre'],
                        $params['anio']
                    ]);

                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Formulario validado correctamente.';
                    break;

                default:
                    $eResponse['message'] = 'Operación no soportada.';
                    return response()->json(['eResponse' => $eResponse], 400);
            }
        } catch (\Exception $ex) {
            $eResponse['errors'][] = $ex->getMessage();
            $eResponse['message'] = 'Error en el servidor.';
            return response()->json(['eResponse' => $eResponse], 500);
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
