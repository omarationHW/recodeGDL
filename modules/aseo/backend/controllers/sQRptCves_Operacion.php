<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($eRequest) {
                case 'get_operaciones':
                    // opcion: 1=ctrol_operacion, 2=cve_operacion, 3=descripcion
                    $opcion = isset($params['opcion']) ? (int)$params['opcion'] : 1;
                    $result = DB::select('SELECT * FROM sp_get_operaciones(?);', [$opcion]);
                    // The result is an array of objects with a single field 'sp_get_operaciones'
                    // Each field is a JSON string, so decode
                    $data = [];
                    foreach ($result as $row) {
                        $data[] = json_decode($row->sp_get_operaciones, true);
                    }
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                default:
                    $eResponse['message'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
