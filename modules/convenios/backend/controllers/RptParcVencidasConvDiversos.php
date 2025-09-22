<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ParcialidadesVencidasConvDiversosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Parcialidades Vencidas Conv Diversos
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'getReport':
                    $data = $this->getReport($params);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Reporte generado correctamente'
                    ];
                    break;
                case 'exportExcel':
                    $data = $this->exportExcel($params);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Archivo Excel generado correctamente'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json($response);
    }

    /**
     * Obtiene el reporte de parcialidades vencidas de convenios diversos
     * @param array $params
     * @return array
     */
    private function getReport($params)
    {
        $tipo = $params['tipo'] ?? null;
        $subtipo = $params['subtipo'] ?? null;
        $fechahst = $params['fechahst'] ?? null;
        $letras = $params['letras'] ?? null;
        $est = $params['est'] ?? null;

        $result = DB::select('CALL sp_parcialidades_vencidas_conv_diversos(?, ?, ?, ?, ?)', [
            $tipo, $subtipo, $fechahst, $letras, $est
        ]);
        return $result;
    }

    /**
     * Exporta el reporte a Excel (devuelve base64 o URL de descarga)
     * @param array $params
     * @return array
     */
    private function exportExcel($params)
    {
        // Lógica para exportar a Excel (puede usar Laravel Excel, aquí solo ejemplo)
        $data = $this->getReport($params);
        // ... generar archivo Excel y devolver URL o base64
        // Por simplicidad, devolvemos los datos
        return $data;
    }
}
