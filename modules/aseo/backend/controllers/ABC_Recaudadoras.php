<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for eRequest/eResponse pattern.
     * Endpoint: /api/execute
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
                case 'getRecaudadoras':
                    $result = DB::select('SELECT * FROM ta_16_recaudadoras ORDER BY num_rec');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'insertRecaudadora':
                    $num_rec = $params['num_rec'] ?? null;
                    $descripcion = $params['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_insert_recaudadora(?, ?)', [$num_rec, $descripcion]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'updateRecaudadora':
                    $num_rec = $params['num_rec'] ?? null;
                    $descripcion = $params['descripcion'] ?? null;
                    $result = DB::select('SELECT * FROM sp_update_recaudadora(?, ?)', [$num_rec, $descripcion]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'deleteRecaudadora':
                    $num_rec = $params['num_rec'] ?? null;
                    $result = DB::select('SELECT * FROM sp_delete_recaudadora(?)', [$num_rec]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }
}
