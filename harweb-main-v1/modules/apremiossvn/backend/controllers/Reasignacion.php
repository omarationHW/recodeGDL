<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ReasignacionController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de Reasignación.
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar_ejecutores|buscar_folios|reasignar_folios",
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
        $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];

        try {
            switch ($action) {
                case 'listar_ejecutores':
                    $response = $this->listarEjecutores($input);
                    break;
                case 'buscar_folios':
                    $response = $this->buscarFolios($input);
                    break;
                case 'reasignar_folios':
                    $response = $this->reasignarFolios($input);
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];
            }
        } catch (\Exception $e) {
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }

        return response()->json(["eResponse" => $response]);
    }

    private function listarEjecutores($input)
    {
        $id_rec = $input['id_rec'] ?? null;
        $id_rec1 = $input['id_rec1'] ?? null;
        $query = "SELECT * FROM ta_15_ejecutores WHERE id_rec >= ? AND id_rec <= ? AND oficio <> '' ORDER BY id_rec, cve_eje";
        $data = DB::select($query, [$id_rec, $id_rec1]);
        return ["success" => true, "message" => "Listado de ejecutores", "data" => $data];
    }

    private function buscarFolios($input)
    {
        $zona = $input['zona'];
        $modulo = $input['modulo'];
        $folio1 = $input['folio1'];
        $folio2 = $input['folio2'];
        $vigencia = $input['vigencia'] ?? '1';
        $query = "SELECT * FROM ta_15_apremios WHERE zona = ? AND modulo = ? AND folio >= ? AND folio <= ? AND vigencia = ? AND ejecutor > 0";
        $data = DB::select($query, [$zona, $modulo, $folio1, $folio2, $vigencia]);
        return ["success" => true, "message" => "Folios encontrados", "data" => $data];
    }

    private function reasignarFolios($input)
    {
        $folios = $input['folios']; // array de id_control
        $nuevo_ejecutor = $input['nuevo_ejecutor'];
        $fecha_entrega2 = $input['fecha_entrega2'];
        $usuario = $input['usuario'];
        $fecha_actualiz = $input['fecha_actualiz'];
        $resultados = [];
        DB::beginTransaction();
        try {
            foreach ($folios as $id_control) {
                $sp_result = DB::select('SELECT sp_reasignar_folio(?, ?, ?, ?, ?) as result', [
                    $id_control, $nuevo_ejecutor, $fecha_entrega2, $usuario, $fecha_actualiz
                ]);
                $resultados[] = ["id_control" => $id_control, "result" => $sp_result[0]->result];
            }
            DB::commit();
            return ["success" => true, "message" => "Folios reasignados correctamente", "data" => $resultados];
        } catch (\Exception $e) {
            DB::rollBack();
            return ["success" => false, "message" => $e->getMessage(), "data" => null];
        }
    }
}
