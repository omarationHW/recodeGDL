<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DrecgoMercadoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (API Unificada)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o Sanctum

        switch ($action) {
            case 'buscarLocal':
                return $this->buscarLocal($params);
            case 'consultarDescuento':
                return $this->consultarDescuento($params);
            case 'altaDescuento':
                return $this->altaDescuento($params, $user);
            case 'cancelarDescuento':
                return $this->cancelarDescuento($params, $user);
            case 'consultarRecaudadoras':
                return $this->consultarRecaudadoras();
            case 'consultarMercados':
                return $this->consultarMercados($params);
            case 'consultarSecciones':
                return $this->consultarSecciones();
            case 'consultarFuncionarios':
                return $this->consultarFuncionarios();
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    public function buscarLocal($params)
    {
        $sql = "SELECT * FROM v_local WHERE ofna = :ofna AND num_merc = :num_merc AND categ = :categ AND secc = :secc AND local = :local";
        if (isset($params['letra']) && $params['letra'] !== '') {
            $sql .= " AND letra = :letra";
        } else {
            $sql .= " AND letra IS NULL";
        }
        if (isset($params['bloque']) && $params['bloque'] !== '') {
            $sql .= " AND bloque = :bloque";
        } else {
            $sql .= " AND bloque IS NULL AND substr(minimo,1,4) <= EXTRACT(YEAR FROM CURRENT_DATE)";
        }
        $sql .= " AND (substr(minimo,1,4) < EXTRACT(YEAR FROM CURRENT_DATE) OR (substr(minimo,6,2) <= EXTRACT(MONTH FROM CURRENT_DATE) AND substr(minimo,1,4) = EXTRACT(YEAR FROM CURRENT_DATE)))";
        $result = DB::select($sql, $params);
        return response()->json(['data' => $result]);
    }

    public function consultarDescuento($params)
    {
        $result = DB::select('SELECT * FROM v_descrecmerc WHERE id_local = :id_local', ['id_local' => $params['id_local']]);
        return response()->json(['data' => $result]);
    }

    public function altaDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer',
            'axoi' => 'required|integer',
            'mesi' => 'required|integer',
            'axof' => 'required|integer',
            'mesf' => 'required|integer',
            'porc' => 'required|integer|min:1|max:100',
            'autoriza' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('SELECT * FROM sp_ins_recarmerc(:id_local, :axoi, :mesi, :axof, :mesf, :usuario, :porc, :autoriza, 1) as control', [
            'id_local' => $params['id_local'],
            'axoi' => $params['axoi'],
            'mesi' => $params['mesi'],
            'axof' => $params['axof'],
            'mesf' => $params['mesf'],
            'usuario' => $user->username,
            'porc' => $params['porc'],
            'autoriza' => $params['autoriza']
        ]);
        return response()->json(['success' => true, 'control' => $result[0]->control ?? null]);
    }

    public function cancelarDescuento($params, $user)
    {
        $validator = Validator::make($params, [
            'id_local' => 'required|integer',
            'axoi' => 'required|integer',
            'mesi' => 'required|integer',
            'axof' => 'required|integer',
            'mesf' => 'required|integer',
            'porc' => 'required|integer',
            'autoriza' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }
        $result = DB::select('SELECT * FROM sp_ins_recarmerc(:id_local, :axoi, :mesi, :axof, :mesf, :usuario, :porc, :autoriza, 2) as control', [
            'id_local' => $params['id_local'],
            'axoi' => $params['axoi'],
            'mesi' => $params['mesi'],
            'axof' => $params['axof'],
            'mesf' => $params['mesf'],
            'usuario' => $user->username,
            'porc' => $params['porc'],
            'autoriza' => $params['autoriza']
        ]);
        return response()->json(['success' => true, 'control' => $result[0]->control ?? null]);
    }

    public function consultarRecaudadoras()
    {
        $result = DB::select('SELECT * FROM c_recaud WHERE recaud < 6');
        return response()->json(['data' => $result]);
    }

    public function consultarMercados($params)
    {
        $result = DB::select('SELECT * FROM v_mercados WHERE ofna = :recaud', ['recaud' => $params['recaud']]);
        return response()->json(['data' => $result]);
    }

    public function consultarSecciones()
    {
        $result = DB::select('SELECT * FROM v_seccion');
        return response()->json(['data' => $result]);
    }

    public function consultarFuncionarios()
    {
        $result = DB::select('SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE cveautoriza <= 5');
        return response()->json(['data' => $result]);
    }
}
