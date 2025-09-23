<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class LigaRequisitosController extends Controller
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
            case 'get_giros':
                return $this->getGiros($params);
            case 'get_requisitos_ligados':
                return $this->getRequisitosLigados($params);
            case 'get_requisitos_disponibles':
                return $this->getRequisitosDisponibles($params);
            case 'add_requisito':
                return $this->addRequisito($params, $user);
            case 'remove_requisito':
                return $this->removeRequisito($params, $user);
            case 'search_giros':
                return $this->searchGiros($params);
            case 'search_requisitos':
                return $this->searchRequisitos($params);
            case 'print_report':
                return $this->printReport($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    public function getGiros($params)
    {
        $giros = DB::select('SELECT id_giro, descripcion, clasificacion, tipo, ctaaplic, reglamentada FROM c_giros WHERE id_giro > 500 AND tipo = ? ORDER BY descripcion', ['L']);
        return response()->json(['success' => true, 'data' => $giros]);
    }

    public function getRequisitosLigados($params)
    {
        $id_giro = $params['id_giro'] ?? null;
        if (!$id_giro) {
            return response()->json(['success' => false, 'message' => 'id_giro requerido'], 400);
        }
        $result = DB::select('SELECT r.id_giro, r.req, c.descripcion FROM giro_req r JOIN c_girosreq c ON c.req = r.req WHERE r.id_giro = ? ORDER BY c.req', [$id_giro]);
        return response()->json(['success' => true, 'data' => $result]);
    }

    public function getRequisitosDisponibles($params)
    {
        $id_giro = $params['id_giro'] ?? null;
        if (!$id_giro) {
            return response()->json(['success' => false, 'message' => 'id_giro requerido'], 400);
        }
        $result = DB::select('SELECT c.req, c.descripcion FROM c_girosreq c WHERE c.req NOT IN (SELECT req FROM giro_req WHERE id_giro = ?) ORDER BY c.req', [$id_giro]);
        return response()->json(['success' => true, 'data' => $result]);
    }

    public function addRequisito($params, $user)
    {
        $id_giro = $params['id_giro'] ?? null;
        $req = $params['req'] ?? null;
        if (!$id_giro || !$req) {
            return response()->json(['success' => false, 'message' => 'id_giro y req requeridos'], 400);
        }
        try {
            DB::statement('CALL sp_ligarequisito_add(?, ?, ?)', [$id_giro, $req, $user ? $user->username : null]);
            return response()->json(['success' => true, 'message' => 'Requisito agregado']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function removeRequisito($params, $user)
    {
        $id_giro = $params['id_giro'] ?? null;
        $req = $params['req'] ?? null;
        if (!$id_giro || !$req) {
            return response()->json(['success' => false, 'message' => 'id_giro y req requeridos'], 400);
        }
        try {
            DB::statement('CALL sp_ligarequisito_remove(?, ?, ?)', [$id_giro, $req, $user ? $user->username : null]);
            return response()->json(['success' => true, 'message' => 'Requisito eliminado']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function searchGiros($params)
    {
        $descripcion = $params['descripcion'] ?? '';
        $giros = DB::select('SELECT * FROM c_giros WHERE id_giro > 500 AND tipo = ? AND descripcion ILIKE ? ORDER BY descripcion', ['L', '%' . $descripcion . '%']);
        return response()->json(['success' => true, 'data' => $giros]);
    }

    public function searchRequisitos($params)
    {
        $descripcion = $params['descripcion'] ?? '';
        $result = DB::select('SELECT * FROM c_girosreq WHERE descripcion ILIKE ? ORDER BY req', ['%' . $descripcion . '%']);
        return response()->json(['success' => true, 'data' => $result]);
    }

    public function printReport($params)
    {
        // Este método puede devolver un PDF generado o un link a un reporte
        // Aquí solo se simula la respuesta
        return response()->json([
            'success' => true,
            'message' => 'Reporte generado',
            'url' => url('/api/reports/liga-requisitos.pdf')
        ]);
    }
}
