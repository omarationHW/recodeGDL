<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones eRequest/eResponse
     */
    public function execute(Request $request)
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
                case 'cons_und_recolec_list':
                    $ejercicio = $params['ejercicio'] ?? date('Y');
                    $order = $params['order'] ?? 'ctrol_recolec';
                    $result = DB::select('SELECT * FROM sp_cons_und_recolec_list(?, ?)', [$ejercicio, $order]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'cons_und_recolec_export':
                    $ejercicio = $params['ejercicio'] ?? date('Y');
                    $order = $params['order'] ?? 'ctrol_recolec';
                    $result = DB::select('SELECT * FROM sp_cons_und_recolec_list(?, ?)', [$ejercicio, $order]);
                    // Aquí se puede implementar la lógica para exportar a Excel si es necesario
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                // Otros casos de uso pueden agregarse aquí
                default:
                    $eResponse['message'] = 'Operación no soportada: ' . $eRequest;
            }
        } catch (\Exception $e) {
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json($eResponse);
    }
}
