<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsCentrosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'get_centros_list':
                return $this->getCentrosList($params);
            case 'get_centros_by_fecha':
                return $this->getCentrosByFecha($params);
            case 'get_centros_by_dependencia':
                return $this->getCentrosByDependencia($params);
            case 'get_centros_by_acta':
                return $this->getCentrosByActa($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                ], 400);
        }
    }

    /**
     * Listado general de pagos en centros de recaudación
     */
    public function getCentrosList($params)
    {
        $query = "SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
                  FROM centros_recaudacion_view
                  ORDER BY fecha DESC, num_recibo DESC";
        $result = DB::select($query);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Filtrar por fecha
     */
    public function getCentrosByFecha($params)
    {
        $validator = Validator::make($params, [
            'fecha' => 'required|date',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }
        $fecha = $params['fecha'];
        $query = "SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
                  FROM centros_recaudacion_view
                  WHERE fecha = ?
                  ORDER BY num_recibo DESC";
        $result = DB::select($query, [$fecha]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Filtrar por dependencia
     */
    public function getCentrosByDependencia($params)
    {
        $validator = Validator::make($params, [
            'id_dependencia' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }
        $id_dependencia = $params['id_dependencia'];
        $query = "SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
                  FROM centros_recaudacion_view
                  WHERE id_dependencia = ?
                  ORDER BY fecha DESC, num_recibo DESC";
        $result = DB::select($query, [$id_dependencia]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Filtrar por acta
     */
    public function getCentrosByActa($params)
    {
        $validator = Validator::make($params, [
            'axo_acta' => 'required|integer',
            'num_acta' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }
        $axo_acta = $params['axo_acta'];
        $num_acta = $params['num_acta'];
        $query = "SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
                  FROM centros_recaudacion_view
                  WHERE axo_acta = ? AND num_acta = ?
                  ORDER BY fecha DESC, num_recibo DESC";
        $result = DB::select($query, [$axo_acta, $num_acta]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }
}
