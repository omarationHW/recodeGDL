<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class EjecutoresController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre ejecutores
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|get|create|update|toggle_vigencia",
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
        $action = $input['action'] ?? '';
        $params = $input['params'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('CALL sp_ejecutores_list(:id_rec)', [
                        'id_rec' => $params['id_rec'] ?? null
                    ]);
                    break;
                case 'get':
                    $result = DB::select('CALL sp_ejecutores_get(:cve_eje, :id_rec)', [
                        'cve_eje' => $params['cve_eje'],
                        'id_rec' => $params['id_rec']
                    ]);
                    break;
                case 'create':
                    $result = DB::select('CALL sp_ejecutores_create(:cve_eje, :ini_rfc, :fec_rfc, :hom_rfc, :nombre, :id_rec, :oficio, :fecinic, :fecterm)', [
                        'cve_eje' => $params['cve_eje'],
                        'ini_rfc' => $params['ini_rfc'],
                        'fec_rfc' => $params['fec_rfc'],
                        'hom_rfc' => $params['hom_rfc'],
                        'nombre' => $params['nombre'],
                        'id_rec' => $params['id_rec'],
                        'oficio' => $params['oficio'],
                        'fecinic' => $params['fecinic'],
                        'fecterm' => $params['fecterm']
                    ]);
                    break;
                case 'update':
                    $result = DB::select('CALL sp_ejecutores_update(:cve_eje, :id_rec, :ini_rfc, :fec_rfc, :hom_rfc, :nombre, :oficio, :fecinic, :fecterm)', [
                        'cve_eje' => $params['cve_eje'],
                        'id_rec' => $params['id_rec'],
                        'ini_rfc' => $params['ini_rfc'],
                        'fec_rfc' => $params['fec_rfc'],
                        'hom_rfc' => $params['hom_rfc'],
                        'nombre' => $params['nombre'],
                        'oficio' => $params['oficio'],
                        'fecinic' => $params['fecinic'],
                        'fecterm' => $params['fecterm']
                    ]);
                    break;
                case 'toggle_vigencia':
                    $result = DB::select('CALL sp_ejecutores_toggle_vigencia(:cve_eje, :id_rec)', [
                        'cve_eje' => $params['cve_eje'],
                        'id_rec' => $params['id_rec']
                    ]);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }
}
