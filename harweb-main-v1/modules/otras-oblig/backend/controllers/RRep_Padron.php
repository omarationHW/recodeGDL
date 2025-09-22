<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones vía eRequest/eResponse
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest['action']) {
                case 'get_concesiones':
                    $vigencia = $eRequest['params']['vigencia'] ?? 'T'; // T: TODOS, V: VIGENTES, C: CANCELADOS
                    $sql = "SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora, a.sector, a.id_zona, a.licencia FROM t34_datos a, t34_status b WHERE a.cve_tab = 3 AND b.id_34_stat = a.id_stat ";
                    if ($vigencia === 'T') {
                        $sql .= "AND b.cve_stat <> 'T' ";
                    } else {
                        $sql .= "AND b.cve_stat = ? ";
                    }
                    $sql .= "ORDER BY a.control";
                    $bindings = ($vigencia === 'T') ? [] : [$vigencia];
                    $concesiones = DB::select($sql, $bindings);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $concesiones;
                    break;
                case 'get_adeudos':
                    $control = $eRequest['params']['control'];
                    $rep = $eRequest['params']['rep'];
                    $fecha = $eRequest['params']['fecha'];
                    $adeudos = DB::select('SELECT * FROM con34_1detade_01(:par_Control, :par_Rep, :par_Fecha)', [
                        'par_Control' => $control,
                        'par_Rep' => $rep,
                        'par_Fecha' => $fecha
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $adeudos;
                    break;
                case 'get_concesiones_with_adeudos':
                    // Para reporte completo: lista de concesiones + adeudos por cada una
                    $vigencia = $eRequest['params']['vigencia'] ?? 'T';
                    $rep = $eRequest['params']['rep'] ?? 'V';
                    $fecha = $eRequest['params']['fecha'] ?? date('Y-m');
                    $sql = "SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora, a.sector, a.id_zona, a.licencia FROM t34_datos a, t34_status b WHERE a.cve_tab = 3 AND b.id_34_stat = a.id_stat ";
                    if ($vigencia === 'T') {
                        $sql .= "AND b.cve_stat <> 'T' ";
                    } else {
                        $sql .= "AND b.cve_stat = ? ";
                    }
                    $sql .= "ORDER BY a.control";
                    $bindings = ($vigencia === 'T') ? [] : [$vigencia];
                    $concesiones = DB::select($sql, $bindings);
                    foreach ($concesiones as &$concesion) {
                        $adeudos = DB::select('SELECT * FROM con34_1detade_01(:par_Control, :par_Rep, :par_Fecha)', [
                            'par_Control' => $concesion->id_34_datos,
                            'par_Rep' => $rep,
                            'par_Fecha' => $fecha
                        ]);
                        $concesion->adeudos = $adeudos;
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = $concesiones;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error('API Execute Error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
