<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsContratosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'searchByContrato':
                    $response['data'] = $this->searchByContrato($params);
                    $response['success'] = true;
                    break;
                case 'searchByNombre':
                    $response['data'] = $this->searchByNombre($params);
                    $response['success'] = true;
                    break;
                case 'searchByDomicilio':
                    $response['data'] = $this->searchByDomicilio($params);
                    $response['success'] = true;
                    break;
                case 'getContratoDetalle':
                    $response['data'] = $this->getContratoDetalle($params);
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
     * Buscar contratos por Colonia, Calle, Folio
     */
    private function searchByContrato($params)
    {
        $colonia = isset($params['colonia']) ? (int)$params['colonia'] : 0;
        $calle = isset($params['calle']) ? (int)$params['calle'] : 0;
        $folio = isset($params['folio']) ? (int)$params['folio'] : 0;
        $result = DB::select('CALL sp_cons_contratos_search_by_contrato(?, ?, ?)', [$colonia, $calle, $folio]);
        return $result;
    }

    /**
     * Buscar contratos por nombre
     */
    private function searchByNombre($params)
    {
        $nombre = isset($params['nombre']) ? $params['nombre'] : '';
        $result = DB::select('CALL sp_cons_contratos_search_by_nombre(?)', [$nombre]);
        return $result;
    }

    /**
     * Buscar contratos por domicilio (desc_calle, numero)
     */
    private function searchByDomicilio($params)
    {
        $desc_calle = isset($params['desc_calle']) ? $params['desc_calle'] : '';
        $numero = isset($params['numero']) ? $params['numero'] : '';
        $result = DB::select('CALL sp_cons_contratos_search_by_domicilio(?, ?)', [$desc_calle, $numero]);
        return $result;
    }

    /**
     * Obtener detalle individual de contrato
     */
    private function getContratoDetalle($params)
    {
        $id_convenio = isset($params['id_convenio']) ? (int)$params['id_convenio'] : 0;
        $result = DB::select('CALL sp_cons_contratos_get_detalle(?)', [$id_convenio]);
        return $result;
    }
}
