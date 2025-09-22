<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones vía eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'getUsuariosPrivilegios':
                    $campo = $params['campo'] ?? 'usuario';
                    $filtro = $params['filtro'] ?? '';
                    $page = $params['page'] ?? 1;
                    $perPage = $params['perPage'] ?? 20;
                    $offset = ($page - 1) * $perPage;
                    $result = DB::select('SELECT * FROM sp_get_usuarios_privilegios(?, ?, ?, ?)', [$campo, $filtro, $offset, $perPage]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getPermisosUsuario':
                    $usuario = $params['usuario'] ?? '';
                    $result = DB::select('SELECT * FROM sp_get_permisos_usuario(?)', [$usuario]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getAuditoriaUsuario':
                    $usuario = $params['usuario'] ?? '';
                    $result = DB::select('SELECT * FROM sp_get_auditoria_usuario(?)', [$usuario]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMovTramites':
                    $usuario = $params['usuario'] ?? '';
                    $fechaini = $params['fechaini'] ?? null;
                    $fechafin = $params['fechafin'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_mov_tramites(?, ?, ?)', [$usuario, $fechaini, $fechafin]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getMovLicencias':
                    $usuario = $params['usuario'] ?? '';
                    $fechaini = $params['fechaini'] ?? null;
                    $fechafin = $params['fechafin'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_mov_licencias(?, ?, ?)', [$usuario, $fechaini, $fechafin]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getDeptos':
                    $result = DB::select('SELECT * FROM sp_get_deptos()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getRevisiones':
                    $usuario = $params['usuario'] ?? '';
                    $fechaini = $params['fechaini'] ?? null;
                    $fechafin = $params['fechafin'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_revisiones(?, ?, ?)', [$fechaini, $fechafin, $usuario]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'eRequest not supported';
            }
        } catch (\Exception $ex) {
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
