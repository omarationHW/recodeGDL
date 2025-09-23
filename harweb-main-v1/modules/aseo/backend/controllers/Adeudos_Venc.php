<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class AdeudosVencController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con Adeudos Vencidos
     * Entrada: {
     *   "eRequest": {
     *     "action": "string", // e.g. 'getTipoAseo', 'buscarContrato', 'getAdeudos', 'getReporte', ...
     *     "params": { ... } // parámetros según acción
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'getTipoAseo':
                    $result = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    break;
                case 'buscarContrato':
                    $result = DB::select('SELECT * FROM buscar_contrato_adeudos_vencidos(?, ?)', [
                        $params['num_contrato'] ?? null,
                        $params['ctrol_aseo'] ?? null
                    ]);
                    break;
                case 'getAdeudos':
                    $result = DB::select('SELECT * FROM get_adeudos_vencidos(?, ?, ?, ?)', [
                        $params['control_contrato'] ?? null,
                        $params['vigencia'] ?? 'V',
                        $params['aso'] ?? null,
                        $params['mes'] ?? null
                    ]);
                    break;
                case 'getReporte':
                    $result = DB::select('SELECT * FROM reporte_adeudos_vencidos(?, ?, ?, ?)', [
                        $params['control_contrato'] ?? null,
                        $params['vigencia'] ?? 'V',
                        $params['aso'] ?? null,
                        $params['mes'] ?? null
                    ]);
                    break;
                case 'getDiaLimite':
                    $result = DB::select('SELECT * FROM ta_16_dia_limite WHERE mes = ?', [
                        $params['mes'] ?? date('n')
                    ]);
                    break;
                case 'getApremios':
                    $result = DB::select('SELECT * FROM get_apremios_adeudos_vencidos(?)', [
                        $params['control_contrato'] ?? null
                    ]);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => $error ? ['error' => $error] : $result
        ]);
    }
}
