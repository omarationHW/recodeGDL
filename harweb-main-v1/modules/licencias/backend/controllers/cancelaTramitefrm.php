<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'action' => 'required|string',
            'params' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid request',
                'errors' => $validator->errors(),
            ], 422);
        }

        $action = $request->input('action');
        $params = $request->input('params', []);

        try {
            switch ($action) {
                case 'get_tramite_by_id':
                    $id_tramite = $params['id_tramite'] ?? null;
                    if (!$id_tramite) {
                        return response()->json(['success' => false, 'message' => 'id_tramite is required'], 400);
                    }
                    $result = DB::select('SELECT * FROM sp_get_tramite_by_id(?)', [$id_tramite]);
                    return response()->json(['success' => true, 'data' => $result]);

                case 'cancel_tramite':
                    $id_tramite = $params['id_tramite'] ?? null;
                    $motivo = $params['motivo'] ?? null;
                    if (!$id_tramite || !$motivo) {
                        return response()->json(['success' => false, 'message' => 'id_tramite and motivo are required'], 400);
                    }
                    $result = DB::select('SELECT * FROM sp_cancel_tramite(?, ?)', [$id_tramite, $motivo]);
                    return response()->json(['success' => true, 'data' => $result]);

                case 'get_giro_by_id':
                    $id_giro = $params['id_giro'] ?? null;
                    if (!$id_giro) {
                        return response()->json(['success' => false, 'message' => 'id_giro is required'], 400);
                    }
                    $result = DB::select('SELECT * FROM sp_get_giro_by_id(?)', [$id_giro]);
                    return response()->json(['success' => true, 'data' => $result]);

                default:
                    return response()->json(['success' => false, 'message' => 'Unknown action'], 400);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Server error',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
