<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class IndividualFolioController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Individual Folio
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|history|periods|catalogs",
     *     "params": {...}
     *   }
     * }
     * Salida: {
     *   "eResponse": {...}
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [];
        try {
            switch ($action) {
                case 'search':
                    $response = $this->searchFolio($params);
                    break;
                case 'history':
                    $response = $this->getHistory($params);
                    break;
                case 'periods':
                    $response = $this->getPeriods($params);
                    break;
                case 'catalogs':
                    $response = $this->getCatalogs($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada'
                    ]], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => $e->getMessage()
            ]], 500);
        }
    }

    /**
     * Buscar folio individual
     */
    private function searchFolio($params)
    {
        $validator = Validator::make($params, [
            'modulo' => 'required|integer',
            'folio' => 'required|integer',
            'recaudadora' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ];
        }
        $result = DB::select('SELECT * FROM sp_individual_folio_search(?, ?, ?)', [
            $params['modulo'],
            $params['folio'],
            $params['recaudadora']
        ]);
        if (empty($result)) {
            return [
                'success' => false,
                'message' => 'No existe Registro con esos datos'
            ];
        }
        return [
            'success' => true,
            'data' => $result[0]
        ];
    }

    /**
     * Obtener historia del folio
     */
    private function getHistory($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ];
        }
        $result = DB::select('SELECT * FROM sp_individual_folio_history(?)', [
            $params['id_control']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Obtener periodos del folio
     */
    private function getPeriods($params)
    {
        $validator = Validator::make($params, [
            'id_control' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ];
        }
        $result = DB::select('SELECT * FROM sp_individual_folio_periods(?)', [
            $params['id_control']
        ]);
        return [
            'success' => true,
            'data' => $result
        ];
    }

    /**
     * Obtener catálogos auxiliares (aplicaciones, recaudadoras, etc)
     */
    private function getCatalogs($params)
    {
        $catalog = $params['catalog'] ?? null;
        switch ($catalog) {
            case 'aplicaciones':
                $data = DB::select('SELECT * FROM sp_catalog_aplicaciones()');
                break;
            case 'recaudadoras':
                $data = DB::select('SELECT * FROM sp_catalog_recaudadoras()');
                break;
            default:
                $data = [];
        }
        return [
            'success' => true,
            'data' => $data
        ];
    }
}
