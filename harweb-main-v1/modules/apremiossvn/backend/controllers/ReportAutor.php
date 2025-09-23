<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ReportAutorController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con ReportAutor
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
                    $response = $this->getReport($params);
                    break;
                case 'getRecInfo':
                    $response = $this->getRecInfo($params);
                    break;
                case 'cancelAutorizados':
                    $response = $this->cancelAutorizados($params);
                    break;
                case 'set100Porciento':
                    $response = $this->set100Porciento($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtener reporte de descuentos autorizados
     * params: rec, fecha1, fecha2
     */
    private function getReport($params)
    {
        $validator = Validator::make($params, [
            'rec' => 'required|integer',
            'fecha1' => 'required|date',
            'fecha2' => 'required|date',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_report_autorizados(?, ?, ?)', [
            $params['rec'], $params['fecha1'], $params['fecha2']
        ]);
        return [
            'status' => 'success',
            'data' => $result,
            'message' => 'Reporte generado correctamente'
        ];
    }

    /**
     * Obtener información de recaudadora
     * params: reca
     */
    private function getRecInfo($params)
    {
        $validator = Validator::make($params, [
            'reca' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_get_rec_info(?)', [
            $params['reca']
        ]);
        return [
            'status' => 'success',
            'data' => $result,
            'message' => 'Información obtenida'
        ];
    }

    /**
     * Cancelar autorizados vigentes
     * params: id_control, fecha_alta
     */
    private function cancelAutorizados($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer',
            'fecha_alta' => 'required|date',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_cancel_autorizados(?, ?)', [
            $params['id_control'], $params['fecha_alta']
        ]);
        return [
            'status' => 'success',
            'data' => $result,
            'message' => 'Autorizados cancelados'
        ];
    }

    /**
     * Poner porcentaje de multa a 100%
     * params: id_control
     */
    private function set100Porciento($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_set_100porciento(?)', [
            $params['id_control']
        ]);
        return [
            'status' => 'success',
            'data' => $result,
            'message' => 'Porcentaje actualizado a 100%'
        ];
    }
}
