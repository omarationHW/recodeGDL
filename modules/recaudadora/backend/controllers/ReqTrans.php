<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ReqTransController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre ReqTrans
     * Entrada: {
     *   "eRequest": {
     *      "action": "list|show|create|update|delete|catalog|folio|folio_data",
     *      ... parámetros ...
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
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'list':
                    $response = $this->list($input);
                    break;
                case 'show':
                    $response = $this->show($input);
                    break;
                case 'create':
                    $response = $this->create($input);
                    break;
                case 'update':
                    $response = $this->update($input);
                    break;
                case 'delete':
                    $response = $this->delete($input);
                    break;
                case 'catalog':
                    $response = $this->catalog($input);
                    break;
                case 'folio':
                    $response = $this->folio($input);
                    break;
                case 'folio_data':
                    $response = $this->folioData($input);
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];
            }
        } catch (\Exception $e) {
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function list($input)
    {
        $folio = $input['folio'] ?? null;
        $result = DB::select('SELECT * FROM reqtransm WHERE folioreq = ?', [$folio]);
        return ["success" => true, "data" => $result];
    }

    private function show($input)
    {
        $id = $input['id'] ?? null;
        $result = DB::selectOne('SELECT * FROM reqtransm WHERE id = ?', [$id]);
        return ["success" => $result ? true : false, "data" => $result];
    }

    private function create($input)
    {
        $validator = Validator::make($input, [
            'folioreq' => 'required|integer',
            'tipo' => 'required|string',
            'cvecta' => 'required|integer',
            'cveejec' => 'required|integer',
            'fecemi' => 'required|date',
            'importe' => 'required|numeric',
            'recargos' => 'required|numeric',
            'multas_ex' => 'required|numeric',
            'multas_otr' => 'required|numeric',
            'gastos' => 'required|numeric',
            'gastos_req' => 'required|numeric',
            'total' => 'required|numeric',
            'observ' => 'nullable|string',
            'usu_act' => 'required|string'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first()];
        }
        $params = [
            $input['folioreq'], $input['tipo'], $input['cvecta'], $input['cveejec'],
            $input['fecemi'], $input['importe'], $input['recargos'], $input['multas_ex'],
            $input['multas_otr'], $input['gastos'], $input['gastos_req'], $input['total'],
            $input['observ'] ?? '', $input['usu_act']
        ];
        $id = DB::selectOne('SELECT sp_reqtransm_create(?,?,?,?,?,?,?,?,?,?,?,?,?,?) as id', $params)->id;
        return ["success" => true, "message" => "Registro creado", "id" => $id];
    }

    private function update($input)
    {
        $validator = Validator::make($input, [
            'id' => 'required|integer',
            'folioreq' => 'required|integer',
            'tipo' => 'required|string',
            'cvecta' => 'required|integer',
            'cveejec' => 'required|integer',
            'fecemi' => 'required|date',
            'importe' => 'required|numeric',
            'recargos' => 'required|numeric',
            'multas_ex' => 'required|numeric',
            'multas_otr' => 'required|numeric',
            'gastos' => 'required|numeric',
            'gastos_req' => 'required|numeric',
            'total' => 'required|numeric',
            'observ' => 'nullable|string',
            'usu_act' => 'required|string'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first()];
        }
        $params = [
            $input['id'], $input['folioreq'], $input['tipo'], $input['cvecta'], $input['cveejec'],
            $input['fecemi'], $input['importe'], $input['recargos'], $input['multas_ex'],
            $input['multas_otr'], $input['gastos'], $input['gastos_req'], $input['total'],
            $input['observ'] ?? '', $input['usu_act']
        ];
        $ok = DB::selectOne('SELECT sp_reqtransm_update(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) as ok', $params)->ok;
        return ["success" => $ok, "message" => $ok ? "Registro actualizado" : "No se pudo actualizar"]; 
    }

    private function delete($input)
    {
        $id = $input['id'] ?? null;
        $ok = DB::selectOne('SELECT sp_reqtransm_delete(?) as ok', [$id])->ok;
        return ["success" => $ok, "message" => $ok ? "Registro eliminado" : "No se pudo eliminar"];
    }

    private function catalog($input)
    {
        $table = $input['table'] ?? null;
        $result = DB::select('SELECT * FROM ' . $table . ' ORDER BY 1');
        return ["success" => true, "data" => $result];
    }

    private function folio($input)
    {
        $foliotrans = $input['foliotrans'] ?? null;
        $result = DB::selectOne('SELECT * FROM actostransm WHERE folio = ?', [$foliotrans]);
        return ["success" => $result ? true : false, "data" => $result];
    }

    private function folioData($input)
    {
        $foliotrans = $input['foliotrans'] ?? null;
        $result = DB::select('SELECT * FROM datos_gral WHERE cvecuenta = (SELECT cvecuenta FROM actostransm WHERE folio = ?)', [$foliotrans]);
        return ["success" => true, "data" => $result];
    }
}
