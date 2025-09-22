<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronContratosController extends Controller
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
                case 'getPadronContratos':
                    $response['data'] = $this->getPadronContratos($params);
                    $response['success'] = true;
                    break;
                case 'getDetalleAdeudos':
                    $response['data'] = $this->getDetalleAdeudos($params);
                    $response['success'] = true;
                    break;
                case 'getDiaLimite':
                    $response['data'] = $this->getDiaLimite($params);
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
     * Obtiene el padrón de contratos filtrado
     */
    private function getPadronContratos($params)
    {
        $tipo = $params['tipo'] ?? 'T';
        $vigencia = $params['vigencia'] ?? 'T';
        $sql = "SELECT * FROM sp16_contratos(:tipo, :vigencia)";
        $result = DB::select($sql, [
            'tipo' => $tipo,
            'vigencia' => $vigencia
        ]);
        return $result;
    }

    /**
     * Obtiene el detalle de adeudos por contrato
     */
    private function getDetalleAdeudos($params)
    {
        $control = $params['control'] ?? null;
        $rep = $params['rep'] ?? 'V';
        $fecha = $params['fecha'] ?? null;
        if (!$control || !$fecha) {
            throw new \Exception('Parámetros requeridos: control, fecha');
        }
        $sql = "SELECT * FROM con16_detade_01(:control, :rep, :fecha)";
        $result = DB::select($sql, [
            'control' => $control,
            'rep' => $rep,
            'fecha' => $fecha
        ]);
        return $result;
    }

    /**
     * Obtiene el día límite para el mes actual
     */
    private function getDiaLimite($params)
    {
        $mes = $params['mes'] ?? date('n');
        $sql = "SELECT * FROM ta_16_dia_limite WHERE mes = :mes";
        $result = DB::select($sql, ['mes' => $mes]);
        return $result;
    }
}
