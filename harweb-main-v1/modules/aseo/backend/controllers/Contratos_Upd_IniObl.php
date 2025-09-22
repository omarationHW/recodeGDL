<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ContratosUpdIniOblController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Contratos_Upd_IniObl
     * Entrada: {
     *   "eRequest": {
     *     "action": "load|search|update|validate|catalogs",
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
        $action = $input['action'] ?? '';
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'catalogs':
                    $response = $this->loadCatalogs();
                    break;
                case 'search':
                    $response = $this->searchContrato($input);
                    break;
                case 'update':
                    $response = $this->updateInicioObligacion($input);
                    break;
                case 'validate':
                    $response = $this->validateFields($input);
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no soportada", "data" => null];
            }
        } catch (\Exception $e) {
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }

        return response()->json(["eResponse" => $response]);
    }

    /**
     * Carga catálogos necesarios (tipos de aseo, meses)
     */
    private function loadCatalogs()
    {
        $tiposAseo = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        $meses = [
            ["value" => 1, "label" => "01"], ["value" => 2, "label" => "02"], ["value" => 3, "label" => "03"],
            ["value" => 4, "label" => "04"], ["value" => 5, "label" => "05"], ["value" => 6, "label" => "06"],
            ["value" => 7, "label" => "07"], ["value" => 8, "label" => "08"], ["value" => 9, "label" => "09"],
            ["value" => 10, "label" => "10"], ["value" => 11, "label" => "11"], ["value" => 12, "label" => "12"]
        ];
        return ["success" => true, "message" => "Catálogos cargados", "data" => ["tiposAseo" => $tiposAseo, "meses" => $meses]];
    }

    /**
     * Busca contrato vigente por número y tipo de aseo
     */
    private function searchContrato($input)
    {
        $validator = Validator::make($input, [
            'num_contrato' => 'required|integer|min:1',
            'ctrol_aseo' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $num_contrato = $input['num_contrato'];
        $ctrol_aseo = $input['ctrol_aseo'];
        $contrato = DB::selectOne('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ? AND status_vigencia = ? LIMIT 1', [$num_contrato, $ctrol_aseo, 'V']);
        if (!$contrato) {
            return ["success" => false, "message" => "No existe contrato vigente con esos datos", "data" => null];
        }
        // Cargar datos anexos (empresa, tipo aseo, zona, recaudadora, etc.)
        $detalles = DB::selectOne('
            SELECT c.*, a.descripcion as empresa_nombre, a.representante, b.tipo_empresa, b.descripcion as tipo_empresa_desc,
                   d.tipo_aseo, d.descripcion as tipo_aseo_desc, e.cve_recolec, e.descripcion as unidad_desc, f.zona, f.sub_zona, f.descripcion as zona_desc, g.recaudadora
            FROM ta_16_contratos c
            JOIN ta_16_empresas a ON a.num_empresa = c.num_empresa AND a.ctrol_emp = c.ctrol_emp
            JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
            JOIN ta_16_tipo_aseo d ON d.ctrol_aseo = c.ctrol_aseo
            JOIN ta_16_unidades e ON e.ctrol_recolec = c.ctrol_recolec
            JOIN ta_16_zonas f ON f.ctrol_zona = c.ctrol_zona
            JOIN ta_12_recaudadoras g ON g.id_rec = c.id_rec
            WHERE c.num_contrato = ? AND c.ctrol_aseo = ? AND c.status_vigencia = ?
            LIMIT 1', [$num_contrato, $ctrol_aseo, 'V']);
        return ["success" => true, "message" => "Contrato encontrado", "data" => $detalles];
    }

    /**
     * Actualiza el inicio de obligación de un contrato
     */
    private function updateInicioObligacion($input)
    {
        $validator = Validator::make($input, [
            'num_contrato' => 'required|integer|min:1',
            'ctrol_aseo' => 'required|integer|min:1',
            'ejercicio' => 'required|integer|min:1989',
            'mes' => 'required|integer|min:1|max:12',
            'documento' => 'required|string|min:1',
            'descripcion_docto' => 'nullable|string',
            'usuario_id' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $num_contrato = $input['num_contrato'];
        $ctrol_aseo = $input['ctrol_aseo'];
        $ejercicio = $input['ejercicio'];
        $mes = $input['mes'];
        $documento = $input['documento'];
        $descripcion_docto = $input['descripcion_docto'] ?? 'SIN CONCEPTO';
        $usuario_id = $input['usuario_id'];
        $fecha_oblig = sprintf('%04d-%02d-01', $ejercicio, $mes);

        // Validar que el contrato existe y está vigente
        $contrato = DB::selectOne('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ? AND status_vigencia = ? LIMIT 1', [$num_contrato, $ctrol_aseo, 'V']);
        if (!$contrato) {
            return ["success" => false, "message" => "No existe contrato vigente con esos datos", "data" => null];
        }
        // Validar que la fecha de inicio de obligación no sea igual a la actual
        if (substr($contrato->aso_mes_oblig, 0, 7) == substr($fecha_oblig, 0, 7)) {
            return ["success" => false, "message" => "La fecha de inicio de obligación es igual a la actual", "data" => null];
        }
        // Ejecutar stored procedure para actualizar inicio de obligación
        $result = DB::select('SELECT * FROM sp16_update_inicio_obligacion(?, ?, ?, ?, ?, ?)', [
            $contrato->control_contrato,
            $fecha_oblig,
            $usuario_id,
            $documento,
            $descripcion_docto,
            $contrato->ctrol_recolec
        ]);
        $row = $result[0] ?? null;
        if ($row && $row->status == 0) {
            return ["success" => true, "message" => $row->leyenda, "data" => null];
        } else {
            return ["success" => false, "message" => $row->leyenda ?? 'Error al actualizar', "data" => null];
        }
    }

    /**
     * Validación de campos (puede usarse para validaciones front)
     */
    private function validateFields($input)
    {
        $validator = Validator::make($input, [
            'num_contrato' => 'required|integer|min:1',
            'ctrol_aseo' => 'required|integer|min:1',
            'ejercicio' => 'required|integer|min:1989',
            'mes' => 'required|integer|min:1|max:12',
            'documento' => 'required|string|min:1',
            'usuario_id' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        return ["success" => true, "message" => "Validación exitosa", "data" => null];
    }
}
