<?php
namespace App\Http\Controllers\SimuladorConvenio;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class SimuladorConvenioController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del simulador de convenios
     * Entrada: {
     *   "eRequest": {
     *     "action": "showMercados|buscarRegistro|simularConvenio|listarPeriodos|...",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $req = $request->input('eRequest');
        $action = $req['action'] ?? null;
        $response = [];
        try {
            switch ($action) {
                case 'showMercados':
                    $response = $this->showMercados();
                    break;
                case 'buscarRegistro':
                    $response = $this->buscarRegistro($req);
                    break;
                case 'simularConvenio':
                    $response = $this->simularConvenio($req);
                    break;
                case 'listarPeriodos':
                    $response = $this->listarPeriodos($req);
                    break;
                default:
                    throw new \Exception('Acción no soportada: ' . $action);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $ex) {
            return response()->json(['eResponse' => [
                'status' => 'error',
                'message' => $ex->getMessage(),
                'trace' => config('app.debug') ? $ex->getTraceAsString() : null
            ]], 500);
        }
    }

    /**
     * Listar mercados (catálogo)
     */
    private function showMercados()
    {
        $mercados = DB::select('SELECT * FROM ta_11_mercados ORDER BY oficina, num_mercado_nvo');
        return [
            'status' => 'ok',
            'mercados' => $mercados
        ];
    }

    /**
     * Buscar registro según módulo y parámetros
     */
    private function buscarRegistro($req)
    {
        $modulo = $req['modulo'] ?? null;
        $p1 = $req['p1'] ?? '';
        $p2 = $req['p2'] ?? '';
        $p3 = $req['p3'] ?? '';
        $p4 = $req['p4'] ?? '';
        $p5 = $req['p5'] ?? '';
        $p6 = $req['p6'] ?? '';
        $p7 = $req['p7'] ?? '';
        $result = DB::select('SELECT * FROM spd_17_buscaregistro(?,?,?,?,?,?,?,?)', [
            $modulo, $p1, $p2, $p3, $p4, $p5, $p6, $p7
        ]);
        if (empty($result)) {
            return [
                'status' => 'not_found',
                'message' => 'No se encontró el registro.'
            ];
        }
        return [
            'status' => 'ok',
            'registro' => $result[0]
        ];
    }

    /**
     * Simular convenio: calcula totales y desglose
     */
    private function simularConvenio($req)
    {
        $modulo = $req['modulo'] ?? null;
        $id_registro = $req['id_registro'] ?? null;
        $anio = $req['anio'] ?? date('Y');
        $mes = $req['mes'] ?? 12;
        $result = DB::select('SELECT * FROM spd_17_liqtotgral(?,?,?,?)', [
            $modulo, $id_registro, $anio, $mes
        ]);
        if (empty($result)) {
            return [
                'status' => 'error',
                'message' => 'No se pudo calcular el convenio.'
            ];
        }
        $totales = $result[0];
        return [
            'status' => 'ok',
            'totales' => $totales
        ];
    }

    /**
     * Listar periodos simulados para un registro
     */
    private function listarPeriodos($req)
    {
        $id_control = $req['id_control'] ?? null;
        $periodos = DB::select('SELECT * FROM ta_15_periodos WHERE control_otr = ? ORDER BY ayo, periodo', [$id_control]);
        return [
            'status' => 'ok',
            'periodos' => $periodos
        ];
    }
}
