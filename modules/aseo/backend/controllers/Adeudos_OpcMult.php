<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class AdeudosOpcMultController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del formulario Adeudos_OpcMult
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar_tipo_aseo|buscar_contrato|listar_recaudadoras|listar_cajas|listar_adeudos|ejecutar_opcion",
     *     ... parámetros ...
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $req = $request->input('eRequest');
        $action = $req['action'] ?? null;
        $response = ["success" => false, "data" => null, "message" => ""];
        try {
            switch ($action) {
                case 'listar_tipo_aseo':
                    $data = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'listar_recaudadoras':
                    $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'listar_cajas':
                    $id_rec = $req['id_rec'] ?? null;
                    $data = DB::select('SELECT caja FROM ta_12_operaciones WHERE id_rec = ? ORDER BY caja', [$id_rec]);
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'buscar_contrato':
                    $num_contrato = $req['num_contrato'] ?? null;
                    $ctrol_aseo = $req['ctrol_aseo'] ?? null;
                    $data = DB::select('SELECT * FROM vw_contratos_detalle WHERE num_contrato = ? AND ctrol_aseo = ?', [$num_contrato, $ctrol_aseo]);
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'listar_adeudos':
                    $control = $req['control_contrato'] ?? null;
                    $data = DB::select('SELECT * FROM con16_detade_021(?)', [$control]);
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'buscar_convenio':
                    $idlc = $req['idlc'] ?? null;
                    $data = DB::select('SELECT convenio FROM vw_convenios WHERE idlc = ?', [$idlc]);
                    $response = ["success" => true, "data" => $data];
                    break;
                case 'ejecutar_opcion':
                    $rows = $req['rows'] ?? [];
                    $opcion = $req['opcion'] ?? null;
                    $fecha = $req['fecha'] ?? null;
                    $reca = $req['reca'] ?? null;
                    $caja = $req['caja'] ?? null;
                    $operacion = $req['operacion'] ?? null;
                    $folio_rcbo = $req['folio_rcbo'] ?? null;
                    $obs = $req['obs'] ?? null;
                    $usuario = $req['usuario'] ?? null;
                    $resultados = [];
                    DB::beginTransaction();
                    foreach ($rows as $row) {
                        $r = DB::select('SELECT * FROM upd16_ade(?,?,?,?,?,?,?,?,?,?) as result', [
                            $row['control_contrato'],
                            $row['periodo'],
                            $row['ctrol_oper'],
                            $opcion,
                            $fecha,
                            $reca,
                            $caja,
                            $operacion,
                            $folio_rcbo,
                            $obs
                        ]);
                        $resultados[] = $r[0]->result ?? null;
                    }
                    DB::commit();
                    $response = ["success" => true, "data" => $resultados];
                    break;
                default:
                    $response['message'] = "Acción no reconocida";
            }
        } catch (\Exception $e) {
            DB::rollBack();
            $response = ["success" => false, "message" => $e->getMessage()];
        }
        return response()->json(["eResponse" => $response]);
    }
}
