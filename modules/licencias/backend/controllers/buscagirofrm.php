<?php

namespace App\Http\Controllers\Licencias;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class BuscagiroController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     * Ruta: POST /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumiendo autenticación JWT

        switch ($action) {
            case 'buscagiro_list':
                return $this->listGiros($params, $user);
            case 'buscagiro_select':
                return $this->selectGiro($params, $user);
            case 'buscagiro_permisos':
                return $this->getPermisos($params, $user);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Listado de giros filtrados por descripción, tipo y permisos
     */
    private function listGiros($params, $user)
    {
        $descripcion = $params['descripcion'] ?? '';
        $tipo = $params['tipo'] ?? 'L';
        $autoev = $params['autoev'] ?? false;
        $pacto = $params['pacto'] ?? false;
        $usuario = $user->username ?? $params['usuario'] ?? null;
        $year = date('Y');

        // Llama al stored procedure
        $giros = DB::select('CALL sp_buscagiro_list(?, ?, ?, ?, ?, ?)', [
            $descripcion, $tipo, $autoev ? 'S' : 'N', $pacto ? 'S' : 'N', $usuario, $year
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Listado de giros obtenido',
            'data' => $giros
        ]);
    }

    /**
     * Selecciona un giro por ID
     */
    private function selectGiro($params, $user)
    {
        $id_giro = $params['id_giro'] ?? null;
        if (!$id_giro) {
            return response()->json([
                'success' => false,
                'message' => 'ID de giro requerido',
                'data' => null
            ], 400);
        }
        $giro = DB::selectOne('SELECT * FROM c_giros WHERE id_giro = ?', [$id_giro]);
        return response()->json([
            'success' => true,
            'message' => 'Giro seleccionado',
            'data' => $giro
        ]);
    }

    /**
     * Obtiene los permisos del usuario para los giros
     */
    private function getPermisos($params, $user)
    {
        $usuario = $user->username ?? $params['usuario'] ?? null;
        $id_permiso_catalogo = $params['id_permiso_catalogo'] ?? 2;
        if (!$usuario) {
            return response()->json([
                'success' => false,
                'message' => 'Usuario requerido',
                'data' => null
            ], 400);
        }
        $permisos = DB::selectOne('SELECT * FROM lic_permisos WHERE usuario = ? AND id_permiso_catalogo = ?', [$usuario, $id_permiso_catalogo]);
        return response()->json([
            'success' => true,
            'message' => 'Permisos obtenidos',
            'data' => $permisos
        ]);
    }
}
