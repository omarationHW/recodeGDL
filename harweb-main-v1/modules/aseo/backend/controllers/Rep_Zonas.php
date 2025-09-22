<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RepZonasController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'success' => false,
                'data' => null,
                'message' => ''
            ]
        ];

        try {
            switch ($action) {
                case 'getZonas':
                    $order = $params['order'] ?? 1;
                    $result = DB::select('SELECT * FROM sp_rep_zonas_get(?);', [$order]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                case 'getZonasReport':
                    $order = $params['order'] ?? 1;
                    $result = DB::select('SELECT * FROM sp_rep_zonas_report(?);', [$order]);
                    $response['eResponse']['success'] = true;
                    $response['eResponse']['data'] = $result;
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('RepZonasController error: ' . $e->getMessage());
            $response['eResponse']['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
