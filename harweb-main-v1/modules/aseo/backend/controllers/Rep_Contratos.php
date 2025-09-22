<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RepContratosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Rep_Contratos
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar_empresas|listar_tipo_aseo|listar_recaudadoras|buscar_empresas|buscar_contratos|reporte_empresa_contratos|reporte_contratos",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $response = [];
        try {
            switch ($action) {
                case 'listar_empresas':
                    $response['empresas'] = DB::select('SELECT * FROM sp16_listar_empresas()');
                    break;
                case 'listar_tipo_aseo':
                    $response['tipos_aseo'] = DB::select('SELECT * FROM sp16_listar_tipo_aseo()');
                    break;
                case 'listar_recaudadoras':
                    $response['recaudadoras'] = DB::select('SELECT * FROM sp16_listar_recaudadoras()');
                    break;
                case 'buscar_empresas':
                    $nombre = $input['nombre'] ?? '';
                    $response['empresas'] = DB::select('SELECT * FROM sp16_buscar_empresas(?)', [$nombre]);
                    break;
                case 'buscar_contratos':
                    $params = [
                        $input['empresa_id'] ?? null,
                        $input['tipo_aseo_id'] ?? null,
                        $input['vigencia'] ?? null,
                        $input['recaudadora_id'] ?? null
                    ];
                    $response['contratos'] = DB::select('SELECT * FROM sp16_buscar_contratos(?,?,?,?)', $params);
                    break;
                case 'reporte_empresa_contratos':
                    $params = [
                        $input['empresa_id'] ?? null,
                        $input['tipo_aseo_id'] ?? null,
                        $input['vigencia'] ?? null,
                        $input['recaudadora_id'] ?? null,
                        $input['orden'] ?? 'ctrol_emp,num_empresa'
                    ];
                    $response['reporte'] = DB::select('SELECT * FROM sp16_reporte_empresa_contratos(?,?,?,?,?)', $params);
                    break;
                case 'reporte_contratos':
                    $params = [
                        $input['empresa_id'] ?? null,
                        $input['tipo_aseo_id'] ?? null,
                        $input['vigencia'] ?? null,
                        $input['recaudadora_id'] ?? null,
                        $input['orden'] ?? 'ctrol_aseo,num_contrato'
                    ];
                    $response['reporte'] = DB::select('SELECT * FROM sp16_reporte_contratos(?,?,?,?,?)', $params);
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }
}
