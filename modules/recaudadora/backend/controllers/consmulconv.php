<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsMulConvController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'get_convenios_by_multa':
                    $response['data'] = $this->getConveniosByMulta($params);
                    $response['success'] = true;
                    break;
                case 'get_convenios_by_expediente':
                    $response['data'] = $this->getConveniosByExpediente($params);
                    $response['success'] = true;
                    break;
                case 'get_convenios_by_range':
                    $response['data'] = $this->getConveniosByRange($params);
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
     * Consulta convenios por id_multa
     */
    private function getConveniosByMulta($params)
    {
        $id_multa = $params['id_multa'] ?? null;
        if (!$id_multa) {
            throw new \Exception('id_multa es requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_convenios_by_multa(?)', [$id_multa]);
        return $result;
    }

    /**
     * Consulta convenios por expediente (letras_exp, axo_exp, numero_exp)
     */
    private function getConveniosByExpediente($params)
    {
        $letras_exp = $params['letras_exp'] ?? null;
        $axo_exp = $params['axo_exp'] ?? null;
        $numero_exp = $params['numero_exp'] ?? null;
        if (!$letras_exp || !$axo_exp || !$numero_exp) {
            throw new \Exception('letras_exp, axo_exp y numero_exp son requeridos');
        }
        $result = DB::select('SELECT * FROM sp_get_convenios_by_expediente(?,?,?)', [$letras_exp, $axo_exp, $numero_exp]);
        return $result;
    }

    /**
     * Consulta convenios por rango de fechas
     */
    private function getConveniosByRange($params)
    {
        $fecha_inicio = $params['fecha_inicio'] ?? null;
        $fecha_fin = $params['fecha_fin'] ?? null;
        if (!$fecha_inicio || !$fecha_fin) {
            throw new \Exception('fecha_inicio y fecha_fin son requeridos');
        }
        $result = DB::select('SELECT * FROM sp_get_convenios_by_range(?,?)', [$fecha_inicio, $fecha_fin]);
        return $result;
    }
}
