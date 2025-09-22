<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DMultaOtrasObligacionesController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o similar

        switch ($action) {
            case 'getObligacionesCatalog':
                return $this->getObligacionesCatalog();
            case 'getPermisoUsuario':
                return $this->getPermisoUsuario($user->username);
            case 'getFuncionarios':
                return $this->getFuncionarios($user->username);
            case 'buscarEncabezado':
                return $this->buscarEncabezado($params);
            case 'buscarDescuentos':
                return $this->buscarDescuentos($params);
            case 'altaDescuento':
                return $this->altaDescuento($params, $user->username);
            case 'cancelarDescuento':
                return $this->cancelarDescuento($params, $user->username);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    public function getObligacionesCatalog()
    {
        $data = DB::table('t34_tablas as t')
            ->join('t34_etiq as e', 't.auto_tab', '=', 'e.cve_tab')
            ->select('t.cve_tab', 't.nombre', 'e.abreviatura', 't.auto_tab')
            ->where('t.auto_tab', '>', 0)
            ->orderBy('t.cve_tab')
            ->get();
        return response()->json(['data' => $data]);
    }

    public function getPermisoUsuario($usuario)
    {
        $permiso = DB::table('autoriza')
            ->where('usuario', $usuario)
            ->where('num_tag', 1319)
            ->first();
        return response()->json(['permiso' => $permiso ? true : false]);
    }

    public function getFuncionarios($usuario)
    {
        $permiso = DB::table('autoriza')
            ->where('usuario', $usuario)
            ->where('num_tag', 1319)
            ->first();
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
        return response()->json(['data' => $funcionarios]);
    }

    public function buscarEncabezado($params)
    {
        $tabla = $params['tabla'] ?? null;
        $control = $params['control'] ?? null;
        if (!$tabla || !$control) {
            return response()->json(['error' => 'Parámetros insuficientes'], 400);
        }
        $result = DB::select('SELECT * FROM cob34_gdatosg_02(?, ?)', [$tabla, $control]);
        return response()->json(['data' => $result]);
    }

    public function buscarDescuentos($params)
    {
        $id_datos = $params['id_datos'] ?? null;
        if (!$id_datos) {
            return response()->json(['error' => 'Parámetro id_datos requerido'], 400);
        }
        $result = DB::table('t34_descmul')->where('id_contrato', $id_datos)->get();
        return response()->json(['data' => $result]);
    }

    public function altaDescuento($params, $usuario)
    {
        $id_datos = $params['id_datos'] ?? null;
        $axoi = $params['axoi'] ?? null;
        $mesi = $params['mesi'] ?? null;
        $axof = $params['axof'] ?? null;
        $mesf = $params['mesf'] ?? null;
        $porc = $params['porc'] ?? null;
        $autoriza = $params['autoriza'] ?? null;
        if (!$id_datos || !$axoi || !$mesi || !$axof || !$mesf || !$porc || !$autoriza) {
            return response()->json(['error' => 'Parámetros insuficientes'], 400);
        }
        $result = DB::select('SELECT * FROM sp_alta_descuento_otras_obligaciones(?,?,?,?,?,?,?,?)', [
            $id_datos, $axoi, $mesi, $axof, $mesf, $usuario, $porc, $autoriza
        ]);
        return response()->json(['result' => $result]);
    }

    public function cancelarDescuento($params, $usuario)
    {
        $id_datos = $params['id_datos'] ?? null;
        $minimo = $params['minimo'] ?? null;
        $maximo = $params['maximo'] ?? null;
        $porc = $params['porc'] ?? null;
        if (!$id_datos || !$minimo || !$maximo || !$porc) {
            return response()->json(['error' => 'Parámetros insuficientes'], 400);
        }
        $result = DB::select('SELECT * FROM sp_cancelar_descuento_otras_obligaciones(?,?,?,?,?)', [
            $id_datos, $minimo, $maximo, $usuario, $porc
        ]);
        return response()->json(['result' => $result]);
    }
}
