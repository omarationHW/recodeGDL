<?php

namespace App\Http\Controllers\Licencias;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class BloquearLicenciaController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $user = $request->user(); // Asumiendo autenticación JWT

        switch ($action) {
            case 'buscarLicencia':
                return $this->buscarLicencia($payload);
            case 'consultarBloqueos':
                return $this->consultarBloqueos($payload);
            case 'bloquearLicencia':
                return $this->bloquearLicencia($payload, $user);
            case 'desbloquearLicencia':
                return $this->desbloquearLicencia($payload, $user);
            case 'catalogoTipoBloqueo':
                return $this->catalogoTipoBloqueo();
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                ], 400);
        }
    }

    /**
     * Buscar licencia por número
     */
    private function buscarLicencia($payload)
    {
        $licencia = DB::selectOne('SELECT * FROM licencias WHERE licencia = ?', [$payload['licencia']]);
        if (!$licencia) {
            return response()->json(['success' => false, 'message' => 'No se encontró licencia con ese número'], 404);
        }
        $giro = DB::selectOne('SELECT descripcion FROM c_giros WHERE id_giro = ?', [$licencia->id_giro]);
        return response()->json([
            'success' => true,
            'licencia' => $licencia,
            'giro' => $giro ? $giro->descripcion : null
        ]);
    }

    /**
     * Consultar bloqueos históricos y activos de una licencia
     */
    private function consultarBloqueos($payload)
    {
        $bloqueos = DB::select('SELECT b.*, c.descripcion as tipo_bloqueo FROM bloqueo b LEFT JOIN c_tipobloqueo c ON c.id = b.bloqueado WHERE b.id_licencia = ? ORDER BY b.fecha_mov DESC', [$payload['id_licencia']]);
        $bloqueosActivos = DB::select('SELECT b.*, c.descripcion as tipo_bloqueo FROM bloqueo b LEFT JOIN c_tipobloqueo c ON c.id = b.bloqueado WHERE b.id_licencia = ? AND b.vigente = ? AND b.bloqueado > 0 ORDER BY b.fecha_mov DESC', [$payload['id_licencia'], 'V']);
        return response()->json([
            'success' => true,
            'bloqueos' => $bloqueos,
            'bloqueos_activos' => $bloqueosActivos
        ]);
    }

    /**
     * Bloquear una licencia
     */
    private function bloquearLicencia($payload, $user)
    {
        $id_licencia = $payload['id_licencia'];
        $tipo_bloqueo = $payload['tipo_bloqueo'];
        $motivo = $payload['motivo'];
        // Validar que la licencia existe y está vigente
        $licencia = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$id_licencia]);
        if (!$licencia) {
            return response()->json(['success' => false, 'message' => 'Licencia no encontrada'], 404);
        }
        if ($licencia->bloqueado > 0) {
            return response()->json(['success' => false, 'message' => 'La licencia ya está bloqueada'], 409);
        }
        // Verificar que no tenga bloqueo activo del mismo tipo
        $bloqueoExistente = DB::selectOne('SELECT * FROM bloqueo WHERE id_licencia = ? AND vigente = ? AND bloqueado = ?', [$id_licencia, 'V', $tipo_bloqueo]);
        if ($bloqueoExistente) {
            return response()->json(['success' => false, 'message' => 'La licencia ya está bloqueada por el mismo tipo'], 409);
        }
        // Ejecutar SP
        $result = DB::select('SELECT * FROM sp_bloquear_licencia(?, ?, ?, ?)', [
            $id_licencia, $tipo_bloqueo, $motivo, $user->username
        ]);
        return response()->json(['success' => true, 'message' => 'Licencia bloqueada correctamente']);
    }

    /**
     * Desbloquear una licencia
     */
    private function desbloquearLicencia($payload, $user)
    {
        $id_licencia = $payload['id_licencia'];
        $tipo_bloqueo = $payload['tipo_bloqueo'];
        $motivo = $payload['motivo'];
        // Validar que la licencia existe y está bloqueada
        $licencia = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$id_licencia]);
        if (!$licencia) {
            return response()->json(['success' => false, 'message' => 'Licencia no encontrada'], 404);
        }
        if ($licencia->bloqueado == 0) {
            return response()->json(['success' => false, 'message' => 'La licencia no está bloqueada'], 409);
        }
        // Ejecutar SP
        $result = DB::select('SELECT * FROM sp_desbloquear_licencia(?, ?, ?, ?)', [
            $id_licencia, $tipo_bloqueo, $motivo, $user->username
        ]);
        return response()->json(['success' => true, 'message' => 'Licencia desbloqueada correctamente']);
    }

    /**
     * Catálogo de tipos de bloqueo
     */
    private function catalogoTipoBloqueo()
    {
        $tipos = DB::select('SELECT * FROM c_tipobloqueo ORDER BY id');
        return response()->json(['success' => true, 'tipos' => $tipos]);
    }
}
