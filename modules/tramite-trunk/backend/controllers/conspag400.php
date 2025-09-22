<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests (eRequest/eResponse pattern)
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
                case 'conspag400_query':
                    $recaud = isset($params['recaud']) ? (int)$params['recaud'] : null;
                    $urbrus = isset($params['urbrus']) ? (int)$params['urbrus'] : null;
                    $cuenta = isset($params['cuenta']) ? (int)$params['cuenta'] : null;

                    if (is_null($recaud) || is_null($urbrus) || is_null($cuenta)) {
                        $response['message'] = 'Parámetros requeridos: recaud, urbrus, cuenta';
                        break;
                    }

                    $result = DB::select('SELECT * FROM sp_conspag400(:recaud, :urbrus, :cuenta)', [
                        'recaud' => $recaud,
                        'urbrus' => $urbrus,
                        'cuenta' => $cuenta
                    ]);

                    $response['success'] = true;
                    $response['data'] = $result;
                    $response['message'] = count($result) > 0 ? 'Pagos encontrados' : 'No se localizaron pagos del AS400';
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
