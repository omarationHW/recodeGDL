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
                case 'listanotificaciones_report':
                    $result = $this->listanotificacionesReport($params);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'eRequest not supported.';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }

    /**
     * Call the stored procedure for the report
     */
    private function listanotificacionesReport($params)
    {
        // Validate required params
        $required = ['axo', 'reca', 'inicio', 'final', 'tipo', 'orden'];
        foreach ($required as $key) {
            if (!isset($params[$key])) {
                throw new \Exception("Missing parameter: $key");
            }
        }
        $axo = (int)$params['axo'];
        $reca = (int)$params['reca'];
        $inicio = (int)$params['inicio'];
        $final = (int)$params['final'];
        $tipo = $params['tipo']; // 'N', 'R', 'S'
        $orden = $params['orden']; // 'lote', 'vigentes', 'dependencia'

        // Call stored procedure
        $sql = "SELECT * FROM sp_listanotificaciones_report(?, ?, ?, ?, ?, ?)";
        $result = DB::select($sql, [$axo, $reca, $inicio, $final, $tipo, $orden]);
        return $result;
    }
}
