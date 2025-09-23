<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class RepdocController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario repdoc
     * Entrada: {
     *   "eRequest": {
     *     "action": "getGiros|getRequisitos|printRequisitos|...",
     *     "params": {...}
     *   }
     * }
     * Salida: {
     *   "eResponse": {...}
     * }
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [];

        try {
            switch ($action) {
                case 'getGiros':
                    $response = $this->getGiros($params);
                    break;
                case 'getGiroById':
                    $response = $this->getGiroById($params);
                    break;
                case 'getRequisitosByGiro':
                    $response = $this->getRequisitosByGiro($params);
                    break;
                case 'printRequisitos':
                    $response = $this->printRequisitos($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'message' => 'Acción no soportada',
                        'data' => null
                    ]], 400);
            }
        } catch (\Exception $e) {
            return response()->json(['eResponse' => [
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null
            ]], 500);
        }

        return response()->json(['eResponse' => [
            'success' => true,
            'message' => 'OK',
            'data' => $response
        ]]);
    }

    private function getGiros($params)
    {
        $giros = DB::select('SELECT id_giro, descripcion, clasificacion, tipo FROM c_giros WHERE tipo = :tipo AND vigente = :vigente ORDER BY descripcion', [
            'tipo' => $params['tipo'] ?? 'L',
            'vigente' => 'V'
        ]);
        return $giros;
    }

    private function getGiroById($params)
    {
        $giro = DB::selectOne('SELECT * FROM c_giros WHERE id_giro = :id_giro', [
            'id_giro' => $params['id_giro']
        ]);
        return $giro;
    }

    private function getRequisitosByGiro($params)
    {
        // Llama al SP para obtener requisitos por giro
        $result = DB::select('SELECT * FROM sp_repdoc_get_requisitos_by_giro(:id_giro)', [
            'id_giro' => $params['id_giro']
        ]);
        return $result;
    }

    private function printRequisitos($params)
    {
        // Llama al SP para obtener los datos del reporte
        $result = DB::select('SELECT * FROM sp_repdoc_get_requisitos_by_giro(:id_giro)', [
            'id_giro' => $params['id_giro']
        ]);
        // Aquí se podría generar un PDF o devolver los datos para que el frontend genere el PDF
        return [
            'reporte' => $result,
            'giro' => DB::selectOne('SELECT * FROM c_giros WHERE id_giro = :id_giro', ['id_giro' => $params['id_giro']])
        ];
    }
}
