<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EstadisticasPeriodosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'success' => false,
                'data' => null,
                'message' => ''
            ]
        ];

        try {
            switch ($action) {
                case 'getEstadisticasPeriodos':
                    $response['eResponse'] = $this->getEstadisticasPeriodos($params);
                    break;
                case 'exportEstadisticasPeriodos':
                    $response['eResponse'] = $this->exportEstadisticasPeriodos($params);
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['success'] = false;
            $response['eResponse']['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Consulta de estadística de periodos
     * params: [axo, adeudo, opc]
     */
    private function getEstadisticasPeriodos($params)
    {
        $axo = isset($params['axo']) ? (int)$params['axo'] : null;
        $adeudo = isset($params['adeudo']) ? (float)$params['adeudo'] : 0;
        $opc = isset($params['opc']) ? (int)$params['opc'] : 1;
        if (!$axo) {
            return [
                'success' => false,
                'data' => null,
                'message' => 'El año de obra (axo) es requerido.'
            ];
        }
        $result = DB::select('CALL spd_17_est_periodo(?, ?)', [$axo, $adeudo]);
        // Si opc==2, filtrar/eliminar detalles
        if ($opc == 2) {
            foreach ($result as &$row) {
                unset($row->colonia, $row->calle, $row->folio);
            }
        }
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Consulta exitosa.'
        ];
    }

    /**
     * Exporta la estadística a Excel (devuelve base64 o URL de descarga)
     */
    private function exportEstadisticasPeriodos($params)
    {
        // Similar a getEstadisticasPeriodos pero genera archivo Excel
        // Aquí solo se simula la respuesta
        return [
            'success' => true,
            'data' => [
                'download_url' => url('/storage/estadisticas_periodos.xlsx')
            ],
            'message' => 'Exportación generada.'
        ];
    }
}
