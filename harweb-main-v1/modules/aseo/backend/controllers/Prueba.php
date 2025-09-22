<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class PruebaController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'message' => 'Acción no reconocida',
            'data' => null
        ];

        switch ($action) {
            case 'prueba_query':
                $response = $this->pruebaQuery($params);
                break;
            case 'licencia_giro_f1':
                $response = $this->licenciaGiroF1($params);
                break;
            default:
                $response['message'] = 'Acción no soportada: ' . $action;
        }
        return response()->json($response);
    }

    /**
     * Ejecuta la consulta principal de prueba (equivalente a Query1 en Delphi)
     * params: { parCtrol: int }
     */
    private function pruebaQuery($params)
    {
        $parCtrol = $params['parCtrol'] ?? null;
        if (!$parCtrol) {
            return [
                'status' => 'error',
                'message' => 'Falta parámetro parCtrol',
                'data' => null
            ];
        }
        $result = DB::select('
            SELECT b.tipo_aseo, a.num_contrato
            FROM ta_16_contratos a
            JOIN ta_16_tipo_aseo b ON b.ctrol_aseo = a.ctrol_aseo
            WHERE a.num_contrato >= 2120
              AND a.ctrol_aseo = :parCtrol
            ORDER BY num_contrato
        ', ['parCtrol' => $parCtrol]);
        return [
            'status' => 'success',
            'message' => 'Consulta ejecutada',
            'data' => $result
        ];
    }

    /**
     * Ejecuta el stored procedure sp16_LicenciaGiro_F1
     * params: { p_tipo: string, p_numero: int }
     */
    private function licenciaGiroF1($params)
    {
        $p_tipo = $params['p_tipo'] ?? null;
        $p_numero = $params['p_numero'] ?? null;
        if (!$p_tipo || !$p_numero) {
            return [
                'status' => 'error',
                'message' => 'Faltan parámetros p_tipo o p_numero',
                'data' => null
            ];
        }
        $result = DB::select('CALL sp16_licenciagiro_f1(:p_tipo, :p_numero)', [
            'p_tipo' => $p_tipo,
            'p_numero' => $p_numero
        ]);
        return [
            'status' => 'success',
            'message' => 'Stored procedure ejecutado',
            'data' => $result
        ];
    }
}
