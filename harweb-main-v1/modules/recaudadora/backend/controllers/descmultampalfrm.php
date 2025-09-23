<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescmultampalController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o session
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'buscarMulta':
                    $response['data'] = $this->buscarMulta($params);
                    $response['success'] = true;
                    break;
                case 'consultarDescuento':
                    $response['data'] = $this->consultarDescuento($params);
                    $response['success'] = true;
                    break;
                case 'agregarDescuento':
                    $response['data'] = $this->agregarDescuento($params, $user);
                    $response['success'] = true;
                    break;
                case 'editarDescuento':
                    $response['data'] = $this->editarDescuento($params, $user);
                    $response['success'] = true;
                    break;
                case 'cancelarDescuento':
                    $response['data'] = $this->cancelarDescuento($params, $user);
                    $response['success'] = true;
                    break;
                case 'listarAutorizadores':
                    $response['data'] = $this->listarAutorizadores();
                    $response['success'] = true;
                    break;
                case 'listarDependencias':
                    $response['data'] = $this->listarDependencias();
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    private function buscarMulta($params)
    {
        $sql = "SELECT * FROM multas WHERE id_dependencia = ? AND axo_acta = ? AND num_acta = ?";
        $multa = DB::selectOne($sql, [
            $params['id_dependencia'],
            $params['axo_acta'],
            $params['num_acta']
        ]);
        if (!$multa) {
            throw new \Exception('No se encontró multa.');
        }
        return $multa;
    }

    private function consultarDescuento($params)
    {
        $sql = "SELECT * FROM descmultampal WHERE id_multa = ? AND estado = 'V'";
        $descuento = DB::selectOne($sql, [$params['id_multa']]);
        return $descuento;
    }

    private function agregarDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_multa' => 'required|integer',
            'tipo_descto' => 'required|in:P,I',
            'valor' => 'required|numeric|min:0',
            'autoriza' => 'required|integer',
            'observacion' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_descmultampal_agregar(?,?,?,?,?,?)', [
            $params['id_multa'],
            $params['tipo_descto'],
            $params['valor'],
            $params['autoriza'],
            $params['observacion'],
            $user->id
        ]);
        return $result[0] ?? null;
    }

    private function editarDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_descmultampal' => 'required|integer',
            'tipo_descto' => 'required|in:P,I',
            'valor' => 'required|numeric|min:0',
            'autoriza' => 'required|integer',
            'observacion' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_descmultampal_editar(?,?,?,?,?,?)', [
            $params['id_descmultampal'],
            $params['tipo_descto'],
            $params['valor'],
            $params['autoriza'],
            $params['observacion'],
            $user->id
        ]);
        return $result[0] ?? null;
    }

    private function cancelarDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_descmultampal' => 'required|integer',
            'motivo' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_descmultampal_cancelar(?,?,?)', [
            $params['id_descmultampal'],
            $params['motivo'],
            $user->id
        ]);
        return $result[0] ?? null;
    }

    private function listarAutorizadores()
    {
        return DB::select('SELECT cveautoriza, descripcion, porcentajetope FROM c_autdescmul WHERE vigencia = ? ORDER BY cveautoriza', ['V']);
    }

    private function listarDependencias()
    {
        return DB::select('SELECT id_dependencia, descripcion FROM c_dependencias WHERE tipo IN (\'M\',\'F\') ORDER BY descripcion');
    }
}
