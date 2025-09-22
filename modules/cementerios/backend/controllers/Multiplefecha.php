<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class MultipleFechaController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'getPagosByFecha':
                    $response['data'] = $this->getPagosByFecha($params);
                    $response['success'] = true;
                    break;
                case 'getPagoDetalle':
                    $response['data'] = $this->getPagoDetalle($params);
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
     * Consulta pagos y títulos por fecha, recaudadora y caja
     * @param array $params
     * @return array
     */
    private function getPagosByFecha($params)
    {
        $validator = Validator::make($params, [
            'fecha' => 'required|date',
            'rec' => 'required|integer',
            'caja' => 'required|string|max:10'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $fecha = $params['fecha'];
        $rec = $params['rec'];
        $caja = $params['caja'];

        // Llama al stored procedure
        $result = DB::select('SELECT * FROM sp_multiple_fecha(:fecha, :rec, :caja)', [
            'fecha' => $fecha,
            'rec' => $rec,
            'caja' => $caja
        ]);
        return $result;
    }

    /**
     * Consulta detalle individual de un pago por control_rcm
     * @param array $params
     * @return array
     */
    private function getPagoDetalle($params)
    {
        $validator = Validator::make($params, [
            'control_rcm' => 'required|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $control_rcm = $params['control_rcm'];
        $result = DB::select('SELECT * FROM sp_pago_detalle(:control_rcm)', [
            'control_rcm' => $control_rcm
        ]);
        return $result;
    }
}
