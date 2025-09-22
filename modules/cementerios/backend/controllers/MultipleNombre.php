<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class MultipleNombreController extends Controller
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
                case 'searchByName':
                    $response['eResponse'] = $this->searchByName($params);
                    break;
                case 'cemeteriesList':
                    $response['eResponse'] = $this->cemeteriesList();
                    break;
                case 'nextPageByName':
                    $response['eResponse'] = $this->nextPageByName($params);
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Buscar registros por nombre (paginado)
     */
    private function searchByName($params)
    {
        $nombre = isset($params['nombre']) ? $params['nombre'] : '';
        $cuenta = isset($params['cuenta']) ? (int)$params['cuenta'] : 0;
        $cem1 = isset($params['cem1']) ? $params['cem1'] : 'A';
        $cem2 = isset($params['cem2']) ? $params['cem2'] : 'Z';
        $limit = isset($params['limit']) ? (int)$params['limit'] : 100;

        $result = DB::select('CALL sp_multiple_nombre_search(?, ?, ?, ?, ?)', [
            $nombre, $cuenta, $cem1, $cem2, $limit
        ]);

        return [
            'success' => true,
            'data' => $result,
            'message' => count($result) ? '' : 'No existe Registro con esos Datos'
        ];
    }

    /**
     * Listado de cementerios
     */
    private function cemeteriesList()
    {
        $result = DB::select('CALL sp_cementerios_list()');
        return [
            'success' => true,
            'data' => $result,
            'message' => ''
        ];
    }

    /**
     * Continuar paginación (siguiente página)
     */
    private function nextPageByName($params)
    {
        // Similar a searchByName pero con cuenta > último control_rcm
        return $this->searchByName($params);
    }
}
