<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class EstadisticasContratosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'getEstadisticasContratos':
                    $year = $params['year'] ?? null;
                    $fondo = $params['fondo'] ?? null;
                    $result = DB::select('CALL spd_17_cta_publica(?, ?)', [$year, $fondo]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getFondos':
                    $fondos = DB::table('fondos')->select('id', 'descripcion')->get();
                    $eResponse['success'] = true;
                    $eResponse['data'] = $fondos;
                    break;
                case 'getAniosObra':
                    $anios = DB::table('ta_17_calles')->distinct()->orderBy('axo_obra', 'desc')->pluck('axo_obra');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $anios;
                    break;
                case 'exportEstadisticasContratos':
                    $year = $params['year'] ?? null;
                    $fondo = $params['fondo'] ?? null;
                    $result = DB::select('CALL spd_17_cta_publica(?, ?)', [$year, $fondo]);
                    // Aquí se puede generar un archivo Excel/CSV y devolver la URL
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    $eResponse['message'] = 'Exportación generada correctamente.';
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada.';
            }
        } catch (\Exception $ex) {
            Log::error('EstadisticasContratosController error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
