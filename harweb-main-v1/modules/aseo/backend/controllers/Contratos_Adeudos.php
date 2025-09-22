<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ContratosAdeudosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
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
                case 'get_contratos_adeudos':
                    $data = $this->getContratosAdeudos($params);
                    $response['success'] = true;
                    $response['data'] = $data;
                    break;
                case 'export_excel':
                    $data = $this->getContratosAdeudos($params);
                    // Aquí deberías generar el archivo Excel y devolver la URL o el archivo
                    $response['success'] = true;
                    $response['data'] = $data; // O la URL del archivo generado
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Lógica para obtener contratos con adeudos
     * Params: parTipo, parVigencia, parReporte, pref
     */
    private function getContratosAdeudos($params)
    {
        $parTipo = $params['parTipo'] ?? 'O';
        $parVigencia = $params['parVigencia'] ?? 'V';
        $parReporte = $params['parReporte'] ?? 'V';
        $pref = $params['pref'] ?? '';

        $sql = "CALL sp16_contratos_adeudo(:parTipo, :parVigencia, :parReporte, :pref)";
        $result = DB::select($sql, [
            'parTipo' => $parTipo,
            'parVigencia' => $parVigencia,
            'parReporte' => $parReporte,
            'pref' => $pref
        ]);
        return $result;
    }
}
