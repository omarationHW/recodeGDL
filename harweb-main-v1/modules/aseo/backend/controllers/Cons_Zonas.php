<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ConsZonasController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     * POST /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'cons_zonas_list':
                    $order = $params['order'] ?? 'ctrol_zona';
                    $result = DB::select('CALL sp_cons_zonas_list(?)', [$order]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'cons_zonas_export_excel':
                    // Export logic handled in frontend, here just return data
                    $order = $params['order'] ?? 'ctrol_zona';
                    $result = DB::select('CALL sp_cons_zonas_list(?)', [$order]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            Log::error($ex);
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
