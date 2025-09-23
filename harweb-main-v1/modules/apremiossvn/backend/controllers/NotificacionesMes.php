<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class NotificacionesMesController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'getNotificacionesMes':
                    $response['data'] = $this->getNotificacionesMes($params);
                    $response['success'] = true;
                    break;
                case 'exportExcel':
                    $response['data'] = $this->exportExcel($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Consulta de notificaciones por mes
     * params: axo_pract, axo_emi, fecha_desde, fecha_hasta
     */
    private function getNotificacionesMes($params)
    {
        $validator = Validator::make($params, [
            'axo_pract' => 'required|integer',
            'axo_emi' => 'required|integer',
            'fecha_desde' => 'required|date',
            'fecha_hasta' => 'required|date',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('CALL spd_15_notif_mes(?, ?, ?, ?)', [
            $params['axo_pract'],
            $params['axo_emi'],
            $params['fecha_desde'],
            $params['fecha_hasta']
        ]);
        return $result;
    }

    /**
     * Exporta a Excel (devuelve datos, la exportación real se hace en frontend)
     */
    private function exportExcel($params)
    {
        // Reutiliza la consulta principal
        return $this->getNotificacionesMes($params);
    }
}
