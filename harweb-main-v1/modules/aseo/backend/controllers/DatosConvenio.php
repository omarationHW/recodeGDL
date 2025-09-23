<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

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
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'getDatosConvenio':
                    $control = $params['control'] ?? null;
                    if (!$control) {
                        throw new \Exception('Parámetro control requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_get_datos_convenio(?)', [$control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getParcialidadesConvenio':
                    $control = $params['control'] ?? null;
                    if (!$control) {
                        throw new \Exception('Parámetro control requerido');
                    }
                    $result = DB::select('SELECT * FROM sp_get_parcialidades_convenio(?)', [$control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getPagoParcialidad':
                    $control = $params['control'] ?? null;
                    $parcial = $params['parcial'] ?? null;
                    if (!$control || !$parcial) {
                        throw new \Exception('Parámetros control y parcial requeridos');
                    }
                    $result = DB::select('SELECT * FROM sp_get_pago_parcialidad(?, ?)', [$control, $parcial]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no soportado';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
