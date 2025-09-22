<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ContratosUpdController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre contratos (actualización).
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|load|update|catalogs",
     *     "data": { ... }
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? '';
        $data = $input['data'] ?? [];
        $response = ["status" => "error", "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'catalogs':
                    $response = $this->getCatalogs();
                    break;
                case 'search':
                    $response = $this->searchContrato($data);
                    break;
                case 'load':
                    $response = $this->loadContrato($data);
                    break;
                case 'update':
                    $response = $this->updateContrato($data);
                    break;
                default:
                    $response = ["status" => "error", "message" => "Acción no reconocida", "data" => null];
            }
        } catch (\Exception $e) {
            $response = ["status" => "error", "message" => $e->getMessage(), "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function getCatalogs()
    {
        $tipoAseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $zonas = DB::select('SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY ctrol_zona, zona, sub_zona');
        $recaudadoras = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        $sectores = ['H', 'J', 'R', 'L'];
        return [
            "status" => "ok",
            "message" => "Catálogos cargados",
            "data" => [
                "tipoAseo" => $tipoAseo,
                "zonas" => $zonas,
                "recaudadoras" => $recaudadoras,
                "sectores" => $sectores
            ]
        ];
    }

    private function searchContrato($data)
    {
        $num_contrato = $data['num_contrato'] ?? null;
        $ctrol_aseo = $data['ctrol_aseo'] ?? null;
        if (!$num_contrato || !$ctrol_aseo) {
            return ["status" => "error", "message" => "Faltan parámetros", "data" => null];
        }
        $contrato = DB::selectOne('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ?', [$num_contrato, $ctrol_aseo]);
        if (!$contrato) {
            return ["status" => "error", "message" => "Contrato no encontrado", "data" => null];
        }
        return ["status" => "ok", "message" => "Contrato encontrado", "data" => $contrato];
    }

    private function loadContrato($data)
    {
        $num_contrato = $data['num_contrato'] ?? null;
        $ctrol_aseo = $data['ctrol_aseo'] ?? null;
        if (!$num_contrato || !$ctrol_aseo) {
            return ["status" => "error", "message" => "Faltan parámetros", "data" => null];
        }
        $contrato = DB::selectOne('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ?', [$num_contrato, $ctrol_aseo]);
        if (!$contrato) {
            return ["status" => "error", "message" => "Contrato no encontrado", "data" => null];
        }
        // Cargar catálogos relacionados
        $tipoAseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $zonas = DB::select('SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY ctrol_zona, zona, sub_zona');
        $recaudadoras = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        $sectores = ['H', 'J', 'R', 'L'];
        return [
            "status" => "ok",
            "message" => "Contrato y catálogos cargados",
            "data" => [
                "contrato" => $contrato,
                "tipoAseo" => $tipoAseo,
                "zonas" => $zonas,
                "recaudadoras" => $recaudadoras,
                "sectores" => $sectores
            ]
        ];
    }

    private function updateContrato($data)
    {
        $validator = Validator::make($data, [
            'control_contrato' => 'required|integer',
            'cantidad_recolec' => 'required|integer|min:1',
            'domicilio' => 'required|string',
            'sector' => 'required|string|in:H,J,R,L',
            'ctrol_zona' => 'required|integer',
            'id_rec' => 'required|integer',
            'aso_mes_oblig' => 'required|date',
            'documento' => 'required|string|min:5',
            'descripcion_docto' => 'required|string|min:5',
            'usuario' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return ["status" => "error", "message" => $validator->errors()->first(), "data" => null];
        }
        $sp_result = DB::select('SELECT * FROM sp16_contratos_upd(:control_contrato, :cantidad_recolec, :domicilio, :sector, :ctrol_zona, :id_rec, :aso_mes_oblig, :documento, :descripcion_docto, :usuario)', [
            'control_contrato' => $data['control_contrato'],
            'cantidad_recolec' => $data['cantidad_recolec'],
            'domicilio' => $data['domicilio'],
            'sector' => $data['sector'],
            'ctrol_zona' => $data['ctrol_zona'],
            'id_rec' => $data['id_rec'],
            'aso_mes_oblig' => $data['aso_mes_oblig'],
            'documento' => $data['documento'],
            'descripcion_docto' => $data['descripcion_docto'],
            'usuario' => $data['usuario']
        ]);
        $result = $sp_result[0] ?? null;
        if ($result && $result->status == 0) {
            return ["status" => "ok", "message" => $result->leyenda, "data" => null];
        } else {
            return ["status" => "error", "message" => $result->leyenda ?? 'Error al actualizar', "data" => null];
        }
    }
}
