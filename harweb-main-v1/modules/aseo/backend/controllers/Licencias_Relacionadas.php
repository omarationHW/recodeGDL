<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LicenciasRelacionadasController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'status' => 'error',
            'message' => 'Acción no reconocida',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'listar_tipos_aseo':
                    $response = $this->listarTiposAseo();
                    break;
                case 'buscar_contrato':
                    $response = $this->buscarContrato($params);
                    break;
                case 'listar_licencias_relacionadas':
                    $response = $this->listarLicenciasRelacionadas($params);
                    break;
                case 'desligar_licencia':
                    $response = $this->desligarLicencia($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    private function listarTiposAseo()
    {
        $tipos = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        return [
            'status' => 'success',
            'message' => 'Tipos de aseo obtenidos',
            'data' => $tipos
        ];
    }

    private function buscarContrato($params)
    {
        $validator = Validator::make($params, [
            'num_contrato' => 'required|integer',
            'ctrol_aseo' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => 'Parámetros inválidos',
                'data' => $validator->errors()
            ];
        }
        $contrato = DB::selectOne('SELECT * FROM ta_16_contratos WHERE num_contrato = ? AND ctrol_aseo = ?', [
            $params['num_contrato'], $params['ctrol_aseo']
        ]);
        if (!$contrato) {
            return [
                'status' => 'error',
                'message' => 'Contrato no encontrado',
                'data' => null
            ];
        }
        return [
            'status' => 'success',
            'message' => 'Contrato encontrado',
            'data' => $contrato
        ];
    }

    private function listarLicenciasRelacionadas($params)
    {
        $validator = Validator::make($params, [
            'opcion' => 'required|in:0,1,2',
            'num_licencia' => 'nullable|integer',
            'control_contrato' => 'nullable|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => 'Parámetros inválidos',
                'data' => $validator->errors()
            ];
        }
        $opcion = $params['opcion'];
        $sql = 'SELECT c.control_contrato, c.num_contrato, c.domicilio AS domicilio_recoleccion_contrato, d.descripcion AS empresa_contrato, d.representante AS representante_contrato, a.num_licencia, b.actividad AS actividad_licencia, b.propietario AS propietario_licencia, b.domicilio AS domicilio_licencia, b.numext_prop, b.ubicacion AS ubicacion_licencia, b.numext_ubic, a.vigencia AS vigencia_rel, e.tipo_aseo FROM ta_16_rel_licgiro a INNER JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato INNER JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp INNER JOIN ta_16_tipo_aseo e ON e.ctrol_aseo = c.ctrol_aseo LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = \'V\'';
        if ($opcion == 0) {
            $sql .= ' WHERE a.control_contrato > 0';
            $bindings = [];
        } elseif ($opcion == 1) {
            $sql .= ' WHERE a.num_licencia = ?';
            $bindings = [$params['num_licencia']];
        } elseif ($opcion == 2) {
            $sql .= ' WHERE a.control_contrato = ?';
            $bindings = [$params['control_contrato']];
        } else {
            $bindings = [];
        }
        $sql .= ' ORDER BY c.num_contrato, a.num_licencia';
        $licencias = DB::select($sql, $bindings);
        return [
            'status' => 'success',
            'message' => 'Licencias relacionadas obtenidas',
            'data' => $licencias
        ];
    }

    private function desligarLicencia($params)
    {
        $validator = Validator::make($params, [
            'num_licencia' => 'required|integer',
            'control_contrato' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => 'Parámetros inválidos',
                'data' => $validator->errors()
            ];
        }
        $result = DB::select('SELECT * FROM sp16_licenciagiro_abc(?, ?, ?, ?)', [
            'D',
            $params['num_licencia'],
            $params['control_contrato'],
            auth()->user() ? auth()->user()->id : 0
        ]);
        if (isset($result[0]->status) && $result[0]->status == 0) {
            return [
                'status' => 'success',
                'message' => $result[0]->leyenda,
                'data' => null
            ];
        } else {
            return [
                'status' => 'error',
                'message' => isset($result[0]->leyenda) ? $result[0]->leyenda : 'Error al desligar licencia',
                'data' => null
            ];
        }
    }
}
