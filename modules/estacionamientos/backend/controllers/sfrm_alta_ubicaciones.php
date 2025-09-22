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

        switch ($operation) {
            case 'alta_ubicacion':
                return $this->altaUbicacion($params);
            default:
                return response()->json([
                    'eResponse' => [
                        'success' => false,
                        'message' => 'Operación no soportada',
                        'data' => null
                    ]
                ], 400);
        }
    }

    /**
     * Alta de Ubicación (equivalente a sp_exc_ubicacion)
     * @param array $params
     * @return \Illuminate\Http\JsonResponse
     */
    private function altaUbicacion($params)
    {
        // Validación básica
        $validator = Validator::make($params, [
            'opc' => 'required|integer',
            'contrato_id' => 'required|integer',
            'tipo_esta' => 'required|string|max:1',
            'calle' => 'required|string|max:255',
            'colonia' => 'required|string|max:255',
            'extencion' => 'required|numeric',
            'acera' => 'required|string|max:1',
            'inter' => 'required|string|max:255',
            'apartir' => 'required|integer',
            'hacia' => 'required|string|max:1',
            'usuario' => 'required|integer'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Datos inválidos',
                    'errors' => $validator->errors()
                ]
            ], 422);
        }

        // Llamada al stored procedure
        try {
            $result = DB::select('SELECT * FROM sp_exc_ubicacion(:opc, :id_ubic, :contrato_id, :tipo_esta, :calle, :colonia, :zona, :subzona, :extencion, :acera, :inter, :inter2, :apartir, :hacia, :usuario)', [
                'opc' => $params['opc'],
                'id_ubic' => $params['id_ubic'] ?? 0,
                'contrato_id' => $params['contrato_id'],
                'tipo_esta' => $params['tipo_esta'],
                'calle' => $params['calle'],
                'colonia' => $params['colonia'],
                'zona' => $params['zona'] ?? 0,
                'subzona' => $params['subzona'] ?? 0,
                'extencion' => $params['extencion'],
                'acera' => $params['acera'],
                'inter' => $params['inter'],
                'inter2' => $params['inter2'] ?? '',
                'apartir' => $params['apartir'],
                'hacia' => $params['hacia'],
                'usuario' => $params['usuario']
            ]);

            $response = isset($result[0]) ? $result[0] : null;

            return response()->json([
                'eResponse' => [
                    'success' => true,
                    'message' => $response->mensaje ?? 'Alta de Ubicación realizada correctamente.',
                    'data' => $response
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Error al ejecutar el procedimiento almacenado',
                    'error' => $e->getMessage()
                ]
            ], 500);
        }
    }
}
