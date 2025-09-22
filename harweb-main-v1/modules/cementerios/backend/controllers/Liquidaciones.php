<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class LiquidacionesController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones de Liquidaciones
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|calculate|print",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "data" => null, "message" => "Unknown action"];

        switch ($action) {
            case 'list_cemeteries':
                $response = $this->listCemeteries();
                break;
            case 'calculate_liquidation':
                $response = $this->calculateLiquidation($params);
                break;
            case 'print_liquidation':
                $response = $this->printLiquidation($params);
                break;
            default:
                $response = ["success" => false, "message" => "Invalid action"];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function listCemeteries()
    {
        $cemeteries = DB::select('SELECT cementerio, nombre, domicilio FROM tc_13_cementerios ORDER BY nombre');
        return ["success" => true, "data" => $cemeteries];
    }

    private function calculateLiquidation($params)
    {
        $validator = Validator::make($params, [
            'cementerio' => 'required|string|max:1',
            'anio_desde' => 'required|integer|min:1998',
            'anio_hasta' => 'required|integer|min:1998',
            'metros' => 'required|numeric|min:0.5',
            'tipo' => 'required|in:F,U,G',
            'nuevo' => 'boolean',
            'mes' => 'required|integer|min:1|max:12'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first()];
        }
        // Llamada al SP
        $result = DB::select('SELECT * FROM sp_liquidaciones_calcular(?,?,?,?,?,?,?)', [
            $params['cementerio'],
            $params['anio_desde'],
            $params['anio_hasta'],
            $params['metros'],
            $params['tipo'],
            $params['nuevo'] ?? false,
            $params['mes']
        ]);
        return ["success" => true, "data" => $result];
    }

    private function printLiquidation($params)
    {
        // Aquí se podría generar un PDF o devolver los datos para impresión
        // Por simplicidad, devolvemos los mismos datos de cálculo
        $calc = $this->calculateLiquidation($params);
        if (!$calc['success']) return $calc;
        // Aquí se podría integrar con un servicio de PDF
        return ["success" => true, "data" => $calc['data'], "pdf_url" => null];
    }
}
