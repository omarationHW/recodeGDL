<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ContratosUpdxContController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario Contratos_UpdxCont
     * Entrada: {
     *   "eRequest": {
     *      "operation": "buscarContrato|buscarEmpresa|actualizarContrato|listarTipoAseo|listarZonas|listarRecaudadoras|listarSectores",
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
        $operation = $input['operation'] ?? null;
        $response = [];

        try {
            switch ($operation) {
                case 'buscarContrato':
                    $response = $this->buscarContrato($input);
                    break;
                case 'buscarEmpresa':
                    $response = $this->buscarEmpresa($input);
                    break;
                case 'altaEmpresa':
                    $response = $this->altaEmpresa($input);
                    break;
                case 'actualizarContrato':
                    $response = $this->actualizarContrato($input);
                    break;
                case 'listarTipoAseo':
                    $response = $this->listarTipoAseo();
                    break;
                case 'listarZonas':
                    $response = $this->listarZonas();
                    break;
                case 'listarRecaudadoras':
                    $response = $this->listarRecaudadoras();
                    break;
                case 'listarSectores':
                    $response = $this->listarSectores();
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Operación no soportada']], 400);
            }
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }

        return response()->json(['eResponse' => $response]);
    }

    private function buscarContrato($input)
    {
        $num_contrato = $input['num_contrato'] ?? null;
        $ctrol_aseo = $input['ctrol_aseo'] ?? null;
        if (!$num_contrato || !$ctrol_aseo) {
            throw new \Exception('Faltan parámetros num_contrato o ctrol_aseo');
        }
        $contrato = DB::selectOne('SELECT * FROM sp16_buscar_contrato(:num_contrato, :ctrol_aseo)', [
            'num_contrato' => $num_contrato,
            'ctrol_aseo' => $ctrol_aseo
        ]);
        if (!$contrato) {
            return ['found' => false, 'message' => 'No existe contrato con el dato capturado'];
        }
        // Cargar combos dependientes
        $zonas = $this->listarZonas();
        $recaudadoras = $this->listarRecaudadoras();
        $sectores = $this->listarSectores();
        return [
            'found' => true,
            'contrato' => $contrato,
            'zonas' => $zonas,
            'recaudadoras' => $recaudadoras,
            'sectores' => $sectores
        ];
    }

    private function buscarEmpresa($input)
    {
        $nombre = $input['nombre'] ?? '';
        $empresas = DB::select('SELECT * FROM sp16_buscar_empresa(:nombre)', [
            'nombre' => $nombre
        ]);
        return ['empresas' => $empresas];
    }

    private function altaEmpresa($input)
    {
        $nombre = $input['nombre'] ?? '';
        if (!$nombre) {
            throw new \Exception('Falta el nombre de la empresa');
        }
        $empresa = DB::selectOne('SELECT * FROM sp16_alta_empresa(:nombre)', [
            'nombre' => $nombre
        ]);
        return ['empresa' => $empresa];
    }

    private function actualizarContrato($input)
    {
        $validator = Validator::make($input, [
            'control_contrato' => 'required|integer',
            'num_empresa' => 'required|integer',
            'ctrol_emp' => 'required|integer',
            'domicilio' => 'required|string',
            'sector' => 'required|string',
            'ctrol_zona' => 'required|integer',
            'id_rec' => 'required|integer',
            'documento' => 'required|string',
            'descripcion_docto' => 'required|string',
            'usuario' => 'required|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception('Datos inválidos: ' . $validator->errors()->first());
        }
        $result = DB::selectOne('SELECT * FROM sp16_actualizar_contrato(:control_contrato, :num_empresa, :ctrol_emp, :domicilio, :sector, :ctrol_zona, :id_rec, :documento, :descripcion_docto, :usuario)', [
            'control_contrato' => $input['control_contrato'],
            'num_empresa' => $input['num_empresa'],
            'ctrol_emp' => $input['ctrol_emp'],
            'domicilio' => $input['domicilio'],
            'sector' => $input['sector'],
            'ctrol_zona' => $input['ctrol_zona'],
            'id_rec' => $input['id_rec'],
            'documento' => $input['documento'],
            'descripcion_docto' => $input['descripcion_docto'],
            'usuario' => $input['usuario']
        ]);
        return ['updated' => $result->updated, 'message' => $result->message];
    }

    private function listarTipoAseo()
    {
        $tipos = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
        return $tipos;
    }

    private function listarZonas()
    {
        $zonas = DB::select('SELECT * FROM ta_16_zonas ORDER BY ctrol_zona, zona, sub_zona');
        return $zonas;
    }

    private function listarRecaudadoras()
    {
        $recaudadoras = DB::select('SELECT * FROM ta_12_recaudadoras ORDER BY id_rec');
        return $recaudadoras;
    }

    private function listarSectores()
    {
        // Sectores fijos
        return [
            ['id' => 'H', 'nombre' => 'H'],
            ['id' => 'J', 'nombre' => 'J'],
            ['id' => 'R', 'nombre' => 'R'],
            ['id' => 'L', 'nombre' => 'L']
        ];
    }
}
