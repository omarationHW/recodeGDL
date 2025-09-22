<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ParcialidadesVencidasController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Parcialidades Vencidas
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'getVencidas':
                    $data = $this->getVencidas($params);
                    $eResponse = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Datos obtenidos correctamente'
                    ];
                    break;
                case 'exportExcel':
                    $data = $this->getVencidas($params);
                    // Aquí se puede implementar la lógica para exportar a Excel
                    // Por simplicidad, devolvemos los datos en JSON
                    $eResponse = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Exportación simulada (devuelve JSON)'
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada: ' . $action;
            }
        } catch (\Exception $ex) {
            Log::error('Error ParcialidadesVencidas: ' . $ex->getMessage());
            $eResponse = [
                'status' => 'error',
                'data' => null,
                'message' => $ex->getMessage()
            ];
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Ejecuta el stored procedure spd_17_parcvencida y retorna los resultados
     * @param array $params
     * @return array
     */
    private function getVencidas($params)
    {
        // Si el SP requiere parámetros, extraerlos de $params
        // En este caso, el SP no requiere parámetros
        $results = DB::select('CALL spd_17_parcvencida()');
        return $results;
    }
}
