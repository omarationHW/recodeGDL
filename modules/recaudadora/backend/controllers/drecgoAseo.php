<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DrecgoAseoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o Sanctum

        switch ($action) {
            case 'searchContrato':
                return $this->searchContrato($params);
            case 'getDescuentos':
                return $this->getDescuentos($params);
            case 'altaDescuento':
                return $this->altaDescuento($params, $user);
            case 'cancelarDescuento':
                return $this->cancelarDescuento($params, $user);
            case 'getTiposAseo':
                return $this->getTiposAseo();
            case 'getFuncionarios':
                return $this->getFuncionarios($user);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada'
                ], 400);
        }
    }

    /**
     * Buscar contrato de aseo
     */
    private function searchContrato($params)
    {
        $tipo = $params['tipo'] ?? null;
        $folio = $params['folio'] ?? null;
        if (!$tipo || !$folio) {
            return response()->json(['success' => false, 'message' => 'Parámetros requeridos'], 422);
        }
        $contrato = DB::table('v_contrato')
            ->where('num_contrato', $folio)
            ->where('cve', $tipo)
            ->first();
        if (!$contrato) {
            return response()->json(['success' => false, 'message' => 'Contrato no encontrado'], 404);
        }
        return response()->json(['success' => true, 'data' => $contrato]);
    }

    /**
     * Obtener descuentos vigentes para un contrato
     */
    private function getDescuentos($params)
    {
        $id_contrato = $params['id_contrato'] ?? null;
        if (!$id_contrato) {
            return response()->json(['success' => false, 'message' => 'Parámetro id_contrato requerido'], 422);
        }
        $descuentos = DB::table('v_descrecaseo')
            ->where('id_contrato', $id_contrato)
            ->orderByDesc('fecha_alta')
            ->get();
        return response()->json(['success' => true, 'data' => $descuentos]);
    }

    /**
     * Alta de descuento de recargos aseo
     */
    private function altaDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_contrato' => 'required|integer',
            'axo_ini' => 'required|integer',
            'mes_ini' => 'required|integer',
            'axo_fin' => 'required|integer',
            'mes_fin' => 'required|integer',
            'porc' => 'required|integer|min:1|max:100',
            'funcionario_id' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 422);
        }
        $result = DB::select('SELECT * FROM ins_recaraseo(?,?,?,?,?,?,?,?) as control', [
            $params['id_contrato'],
            $params['axo_ini'],
            $params['mes_ini'],
            $params['axo_fin'],
            $params['mes_fin'],
            $user->username,
            $params['porc'],
            1 // par_opc=1 para alta
        ]);
        return response()->json(['success' => true, 'control' => $result[0]->control ?? null]);
    }

    /**
     * Cancelar descuento
     */
    private function cancelarDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_contrato' => 'required|integer',
            'axo_ini' => 'required|integer',
            'mes_ini' => 'required|integer',
            'axo_fin' => 'required|integer',
            'mes_fin' => 'required|integer',
            'porc' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 422);
        }
        $result = DB::select('SELECT * FROM ins_recaraseo(?,?,?,?,?,?,?,?) as control', [
            $params['id_contrato'],
            $params['axo_ini'],
            $params['mes_ini'],
            $params['axo_fin'],
            $params['mes_fin'],
            $user->username,
            $params['porc'],
            2 // par_opc=2 para cancelación
        ]);
        return response()->json(['success' => true, 'control' => $result[0]->control ?? null]);
    }

    /**
     * Obtener tipos de aseo
     */
    private function getTiposAseo()
    {
        $tipos = DB::table('v_tipo_aseo')->get();
        return response()->json(['success' => true, 'data' => $tipos]);
    }

    /**
     * Obtener funcionarios autorizados
     */
    private function getFuncionarios($user)
    {
        // Si el usuario tiene permiso especial (num_tag=1319), mostrar todos
        $permiso = DB::table('autoriza')
            ->where('usuario', $user->username)
            ->where('num_tag', 1319)
            ->exists();
        if ($permiso) {
            $funcionarios = DB::table('c_autdescrec')
                ->where('vigencia', 'V')
                ->orderByDesc('cveautoriza')
                ->get();
        } else {
            $funcionarios = DB::table('c_autdescrec')
                ->where('funcionario', 'N')
                ->where('vigencia', 'V')
                ->get();
        }
        return response()->json(['success' => true, 'data' => $funcionarios]);
    }
}
