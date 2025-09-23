<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
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
                case 'getEstacionometroReport':
                    $vigencia = $params['vigencia'] ?? 'todas';
                    $clave_practicado = $params['clave_practicado'] ?? 'todas';
                    $colonia = $params['colonia'] ?? '';
                    $oficina = $params['oficina'] ?? null;
                    $result = DB::select('SELECT * FROM rpt_listaxreg_estacionometro(:vigencia, :clave_practicado, :colonia, :oficina)', [
                        'vigencia' => $vigencia,
                        'clave_practicado' => $clave_practicado,
                        'colonia' => $colonia,
                        'oficina' => $oficina
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getRecaudadoraZona':
                    $rec = $params['rec'] ?? null;
                    $result = DB::select('SELECT * FROM get_recaudadora_zona(:rec)', [
                        'rec' => $rec
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
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
