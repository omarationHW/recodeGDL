<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ContratosUpd01Controller extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Contratos_Upd_01
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
     *     "data": { ... }
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
        $data = $input['data'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'getTipoAseo':
                    $result = DB::select('SELECT * FROM sp_get_tipo_aseo()');
                    break;
                case 'getUnidades':
                    $ejercicio = $data['ejercicio'] ?? date('Y');
                    $result = DB::select('SELECT * FROM sp_get_unidades(?)', [$ejercicio]);
                    break;
                case 'getZonas':
                    $result = DB::select('SELECT * FROM sp_get_zonas()');
                    break;
                case 'getRecaudadoras':
                    $result = DB::select('SELECT * FROM sp_get_recaudadoras()');
                    break;
                case 'buscarContrato':
                    $numContrato = $data['num_contrato'] ?? null;
                    $ctrolAseo = $data['ctrol_aseo'] ?? null;
                    $result = DB::select('SELECT * FROM sp_busca_contrato(?, ?)', [$numContrato, $ctrolAseo]);
                    break;
                case 'buscarEmpresas':
                    $nombre = $data['nombre'] ?? '';
                    $result = DB::select('SELECT * FROM sp_buscar_empresas(?)', [$nombre]);
                    break;
                case 'buscarConvenio':
                    $idlc = $data['idlc'] ?? null;
                    $result = DB::select('SELECT * FROM sp_busca_convenio(?)', [$idlc]);
                    break;
                case 'verLicenciasRelacionadas':
                    $controlContrato = $data['control_contrato'] ?? null;
                    $result = DB::select('SELECT * FROM sp_licencias_relacionadas(?)', [$controlContrato]);
                    break;
                case 'aplicarLicenciaGiro':
                    $opc = $data['opc'] ?? null;
                    $licenciaGiro = $data['licencia_giro'] ?? null;
                    $controlContrato = $data['control_contrato'] ?? null;
                    $result = DB::select('SELECT * FROM sp_licencia_giro_abc(?, ?, ?)', [$opc, $licenciaGiro, $controlContrato]);
                    break;
                case 'actualizarContrato':
                    // Validar y mapear todos los parámetros
                    $params = [
                        $data['control_cont'] ?? null,
                        $data['num_emp'] ?? null,
                        $data['ctrol_emp'] ?? null,
                        $data['cant_recolec'] ?? null,
                        $data['ctrol_zona'] ?? null,
                        $data['id_rec'] ?? null,
                        $data['axo_ini'] ?? null,
                        $data['mes_ini'] ?? null,
                        $data['opcion'] ?? null,
                        $data['cve_recolec'] ?? null,
                        $data['domicilio'] ?? null,
                        $data['sector'] ?? null,
                        $data['docto'] ?? null,
                        $data['descrip'] ?? null
                    ];
                    $result = DB::select('SELECT * FROM sp_upd16_contrato_01(?,?,?,?,?,?,?,?,?,?,?,?,?,?)', $params);
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
