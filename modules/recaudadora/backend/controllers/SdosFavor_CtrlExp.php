<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class SdosFavorCtrlExpController extends Controller
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
            case 'getStatusOptions':
                return response()->json([
                    'status' => 'success',
                    'data' => [
                        ['label' => 'APLICADOS', 'value' => 'A'],
                        ['label' => 'ASIGNADOS', 'value' => 'AS'],
                        ['label' => 'PENDIENTES', 'value' => 'P'],
                        ['label' => 'RECHAZADOS', 'value' => 'RC'],
                        ['label' => 'RECIBIDOS', 'value' => 'R'],
                        ['label' => 'TERMINADO', 'value' => 'T'],
                        ['label' => 'TODOS', 'value' => ''],
                        ['label' => 'TRAMITADOS', 'value' => 'TR']
                    ]
                ]);
            case 'searchFolios':
                $status = $params['status'] ?? '';
                $folios = DB::select('SELECT folio, axofol FROM solic_sdosfavor ' . ($status !== '' ? 'WHERE status = ?' : '') . ' ORDER BY folio ASC', $status !== '' ? [$status] : []);
                return response()->json([
                    'status' => 'success',
                    'data' => $folios
                ]);
            case 'assignFolios':
                $folios = $params['folios'] ?? [];
                $newStatus = $params['new_status'] ?? 'AS';
                if (empty($folios)) {
                    return response()->json(['status' => 'error', 'message' => 'No folios selected']);
                }
                DB::beginTransaction();
                try {
                    foreach ($folios as $folio) {
                        DB::update('UPDATE solic_sdosfavor SET status = ? WHERE folio = ?', [$newStatus, $folio]);
                    }
                    DB::commit();
                    return response()->json(['status' => 'success', 'message' => 'Folios asignados correctamente']);
                } catch (\Exception $e) {
                    DB::rollBack();
                    return response()->json(['status' => 'error', 'message' => $e->getMessage()]);
                }
            case 'getTotalFolios':
                $status = $params['status'] ?? '';
                $count = DB::selectOne('SELECT COUNT(*) as total FROM solic_sdosfavor ' . ($status !== '' ? 'WHERE status = ?' : ''), $status !== '' ? [$status] : []);
                return response()->json(['status' => 'success', 'data' => $count->total]);
            default:
                return response()->json(['status' => 'error', 'message' => 'Acción no soportada']);
        }
    }
}
