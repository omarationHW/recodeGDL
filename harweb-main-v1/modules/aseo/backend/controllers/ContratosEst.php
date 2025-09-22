<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ContratosEstController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'getFilters':
                    $response['data'] = $this->getFilters();
                    $response['success'] = true;
                    break;
                case 'getEstadistico':
                    $response['data'] = $this->getEstadistico($params);
                    $response['success'] = true;
                    break;
                case 'getTiposAseo':
                    $response['data'] = $this->getTiposAseo();
                    $response['success'] = true;
                    break;
                case 'getOficinas':
                    $response['data'] = $this->getOficinas();
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error($e);
        }
        return response()->json($response);
    }

    /**
     * Devuelve los filtros iniciales (vigencias, oficinas, tipos de aseo, etc)
     */
    private function getFilters()
    {
        return [
            'vigencias' => [
                ['value' => 'T', 'label' => 'TODOS'],
                ['value' => 'V', 'label' => 'VIGENTES'],
                ['value' => 'C', 'label' => 'CANCELADOS']
            ],
            'oficinas' => $this->getOficinas(),
            'tipos_aseo' => $this->getTiposAseo(),
            'vigencias_adeudos' => [
                ['value' => 'T', 'label' => 'TODOS'],
                ['value' => 'V', 'label' => 'VIGENTES'],
                ['value' => 'P', 'label' => 'PAGADOS'],
                ['value' => 'C', 'label' => 'CANCELADOS'],
                ['value' => 'S', 'label' => 'SUSPENDIDOS / Condonados']
            ],
            'grupo_adeudos' => [
                ['value' => 0, 'label' => 'POR PERIODO DE ADEUDO'],
                ['value' => 1, 'label' => 'POR PERIODO DE PAGO'],
                ['value' => 2, 'label' => 'HISTORICO']
            ],
            'adeudos_visual' => [
                ['value' => 0, 'label' => 'CON ADEUDOS'],
                ['value' => 1, 'label' => 'SIN ADEUDOS']
            ]
        ];
    }

    /**
     * Devuelve el listado de oficinas recaudadoras
     */
    private function getOficinas()
    {
        return DB::table('ta_12_recaudadoras')
            ->select(DB::raw('id_rec as value, recaudadora as label'))
            ->orderBy('id_rec')
            ->get();
    }

    /**
     * Devuelve el listado de tipos de aseo
     */
    private function getTiposAseo()
    {
        return DB::table('ta_16_tipo_aseo')
            ->select(DB::raw('ctrol_aseo as value, tipo_aseo, descripcion, CONCAT(ctrol_aseo, " - ", tipo_aseo, " - ", descripcion) as label'))
            ->orderBy('ctrol_aseo')
            ->get();
    }

    /**
     * Ejecuta el estadístico de contratos
     * @param array $params
     * @return array
     */
    private function getEstadistico($params)
    {
        // Validación básica
        $vigencia = $params['vigencia'] ?? 'T';
        $oficina = $params['oficina'] ?? 0;
        $tipo_aseo = $params['tipo_aseo'] ?? 999;
        $vig_adeudos = $params['vig_adeudos'] ?? 'T';
        $grupo_adeudos = $params['grupo_adeudos'] ?? 0;
        $periodo_inicio = $params['periodo_inicio'] ?? null;
        $periodo_fin = $params['periodo_fin'] ?? null;
        $fecha_inicio = $params['fecha_inicio'] ?? null;
        $fecha_fin = $params['fecha_fin'] ?? null;
        $adeudos_visual = $params['adeudos_visual'] ?? 0;

        // Llama al stored procedure
        $result = DB::select('SELECT * FROM sp_contratos_estadistico(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $vigencia,
            $oficina,
            $tipo_aseo,
            $vig_adeudos,
            $grupo_adeudos,
            $periodo_inicio,
            $periodo_fin,
            $fecha_inicio,
            $fecha_fin,
            $adeudos_visual
        ]);
        return $result;
    }
}
