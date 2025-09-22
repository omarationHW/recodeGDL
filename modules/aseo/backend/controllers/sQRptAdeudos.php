<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar procedimientos almacenados
     * Entrada: {
     *   "eRequest": {
     *     "procedure": "nombre_del_sp",
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
        if (!$input || !isset($input['procedure'])) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => 'Parámetro procedure requerido.'
                ]
            ], 400);
        }

        $procedure = $input['procedure'];
        $params = isset($input['params']) ? $input['params'] : [];

        try {
            switch ($procedure) {
                case 'rpt_adeudos_general':
                    $result = $this->rptAdeudosGeneral($params);
                    break;
                default:
                    return response()->json([
                        'eResponse' => [
                            'success' => false,
                            'message' => 'Procedimiento no soportado.'
                        ]
                    ], 400);
            }
            return response()->json(['eResponse' => [
                'success' => true,
                'data' => $result
            ]]);
        } catch (\Exception $e) {
            return response()->json([
                'eResponse' => [
                    'success' => false,
                    'message' => $e->getMessage()
                ]
            ], 500);
        }
    }

    /**
     * Ejecuta el SP de reporte de adeudos generales
     * @param array $params
     * @return array
     */
    private function rptAdeudosGeneral($params)
    {
        // Parámetros esperados
        $sel_emp = isset($params['sel_emp']) ? (int)$params['sel_emp'] : 1;
        $sel_cont = isset($params['sel_cont']) ? (int)$params['sel_cont'] : 1;
        $ofna = isset($params['ofna']) ? (int)$params['ofna'] : 0;
        $opcion = isset($params['opcion']) ? (int)$params['opcion'] : 1;
        $num_emp = isset($params['num_emp']) ? (int)$params['num_emp'] : 0;
        $num_cont = isset($params['num_cont']) ? (int)$params['num_cont'] : 0;
        $sel_ctrol_aseo = isset($params['sel_ctrol_aseo']) ? (int)$params['sel_ctrol_aseo'] : 0;
        $vig_cont = isset($params['vig_cont']) ? $params['vig_cont'] : 'T';
        $vig_adeudos = isset($params['vig_adeudos']) ? $params['vig_adeudos'] : 'T';

        // Llamada al SP
        $sql = "SELECT * FROM rpt_adeudos_general(?, ?, ?, ?, ?, ?, ?, ?, ?);";
        $bindings = [
            $sel_emp, $sel_cont, $ofna, $opcion, $num_emp, $num_cont, $sel_ctrol_aseo, $vig_cont, $vig_adeudos
        ];
        $rows = DB::select($sql, $bindings);
        return $rows;
    }
}
