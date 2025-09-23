<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RepTiposAseoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'getTiposAseoReport':
                    $order = $params['order'] ?? 1;
                    $result = DB::select('SELECT * FROM sp_rep_tipos_aseo_report(?)', [$order]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getTiposAseoOptions':
                    $result = DB::select('SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            Log::error('RepTiposAseoController error: ' . $e->getMessage());
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
