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
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'errors' => [],
            'messages' => []
        ];

        switch ($operation) {
            case 'validate_hasta_form':
                $validator = Validator::make($params, [
                    'bimestre' => 'required|integer|min:1|max:6',
                    'anio' => 'required|integer|min:1970|max:' . date('Y'),
                ], [
                    'bimestre.required' => 'El campo Bimestre es obligatorio.',
                    'bimestre.integer' => 'El Bimestre debe ser un número.',
                    'bimestre.min' => 'El Bimestre debe ser entre 1 y 6.',
                    'bimestre.max' => 'El Bimestre debe ser entre 1 y 6.',
                    'anio.required' => 'El campo Año es obligatorio.',
                    'anio.integer' => 'El Año debe ser un número.',
                    'anio.min' => 'El Año debe ser mayor o igual a 1970.',
                    'anio.max' => 'El Año no puede ser mayor al actual.',
                ]);

                if ($validator->fails()) {
                    $eResponse['errors'] = $validator->errors()->all();
                    $eResponse['success'] = false;
                } else {
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'bimestre' => $params['bimestre'],
                        'anio' => $params['anio']
                    ];
                    $eResponse['messages'][] = 'Validación exitosa.';
                }
                break;

            case 'save_hasta_form':
                // Lógica de guardado (si aplica, aquí solo validamos y retornamos)
                $validator = Validator::make($params, [
                    'bimestre' => 'required|integer|min:1|max:6',
                    'anio' => 'required|integer|min:1970|max:' . date('Y'),
                ]);
                if ($validator->fails()) {
                    $eResponse['errors'] = $validator->errors()->all();
                    $eResponse['success'] = false;
                } else {
                    // Si se requiere guardar en BD, llamar SP aquí
                    // DB::select('SELECT * FROM sp_save_hasta_form(?, ?)', [$params['bimestre'], $params['anio']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'bimestre' => $params['bimestre'],
                        'anio' => $params['anio']
                    ];
                    $eResponse['messages'][] = 'Datos guardados correctamente.';
                }
                break;

            default:
                $eResponse['errors'][] = 'Operación no soportada.';
                break;
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
