<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DependenciasController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'get_dependencias':
                return $this->getDependencias($params);
            case 'get_tramite_inspecciones':
                return $this->getTramiteInspecciones($params);
            case 'add_inspeccion':
                return $this->addInspeccion($params, $user);
            case 'delete_inspeccion':
                return $this->deleteInspeccion($params, $user);
            case 'get_tramite_info':
                return $this->getTramiteInfo($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                ], 400);
        }
    }

    /**
     * Obtener catálogo de dependencias activas
     */
    public function getDependencias($params)
    {
        $dependencias = DB::select('SELECT id_dependencia, descripcion FROM c_dependencias WHERE licencias = 1 AND vigente = \'V\' ORDER BY descripcion');
        return response()->json([
            'success' => true,
            'data' => $dependencias
        ]);
    }

    /**
     * Obtener inspecciones actuales de un trámite (por id_tramite)
     */
    public function getTramiteInspecciones($params)
    {
        $tramiteId = $params['id_tramite'] ?? null;
        if (!$tramiteId) {
            return response()->json(['success' => false, 'message' => 'id_tramite requerido'], 400);
        }
        $inspecciones = DB::select('SELECT r.id_revision, r.id_dependencia, d.descripcion FROM revisiones r INNER JOIN c_dependencias d ON r.id_dependencia = d.id_dependencia WHERE r.id_tramite = ? AND r.estatus = \'V\' ORDER BY d.descripcion', [$tramiteId]);
        return response()->json([
            'success' => true,
            'data' => $inspecciones
        ]);
    }

    /**
     * Agregar inspección a un trámite
     */
    public function addInspeccion($params, $user)
    {
        $tramiteId = $params['id_tramite'] ?? null;
        $idDependencia = $params['id_dependencia'] ?? null;
        if (!$tramiteId || !$idDependencia) {
            return response()->json(['success' => false, 'message' => 'id_tramite y id_dependencia requeridos'], 400);
        }
        // Validar que no exista ya
        $exists = DB::selectOne('SELECT 1 FROM revisiones WHERE id_tramite = ? AND id_dependencia = ? AND estatus = \'V\'', [$tramiteId, $idDependencia]);
        if ($exists) {
            return response()->json(['success' => false, 'message' => 'Ya existe esta inspección para el trámite'], 409);
        }
        // Insertar revisión
        $idRevision = DB::table('revisiones')->insertGetId([
            'id_tramite' => $tramiteId,
            'id_dependencia' => $idDependencia,
            'fecha_inicio' => now(),
            'estatus' => 'V',
            'descripcion' => DB::table('c_dependencias')->where('id_dependencia', $idDependencia)->value('descripcion'),
        ]);
        // Insertar seguimiento
        DB::table('seg_revision')->insert([
            'id_revision' => $idRevision,
            'estatus' => 'V',
            'feccap' => now(),
            'usr_revisa' => $user ? $user->username : 'api',
        ]);
        return response()->json(['success' => true, 'message' => 'Inspección agregada']);
    }

    /**
     * Eliminar inspección de un trámite
     */
    public function deleteInspeccion($params, $user)
    {
        $tramiteId = $params['id_tramite'] ?? null;
        $idDependencia = $params['id_dependencia'] ?? null;
        if (!$tramiteId || !$idDependencia) {
            return response()->json(['success' => false, 'message' => 'id_tramite y id_dependencia requeridos'], 400);
        }
        $revision = DB::table('revisiones')
            ->where('id_tramite', $tramiteId)
            ->where('id_dependencia', $idDependencia)
            ->where('estatus', 'V')
            ->first();
        if (!$revision) {
            return response()->json(['success' => false, 'message' => 'No existe la inspección para eliminar'], 404);
        }
        // Eliminar seguimiento
        DB::table('seg_revision')->where('id_revision', $revision->id_revision)->delete();
        // Eliminar revisión
        DB::table('revisiones')->where('id_revision', $revision->id_revision)->delete();
        return response()->json(['success' => true, 'message' => 'Inspección eliminada']);
    }

    /**
     * Obtener información básica del trámite (para mostrar en el formulario)
     */
    public function getTramiteInfo($params)
    {
        $tramiteId = $params['id_tramite'] ?? null;
        if (!$tramiteId) {
            return response()->json(['success' => false, 'message' => 'id_tramite requerido'], 400);
        }
        $tramite = DB::selectOne('SELECT t.id_tramite, t.propietario, t.ubicacion, t.estatus FROM tramites t WHERE t.id_tramite = ?', [$tramiteId]);
        if (!$tramite) {
            return response()->json(['success' => false, 'message' => 'Trámite no encontrado'], 404);
        }
        return response()->json(['success' => true, 'data' => $tramite]);
    }
}
