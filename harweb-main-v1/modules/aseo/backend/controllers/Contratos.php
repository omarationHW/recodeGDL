<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ContratosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre contratos
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar|buscar|excel",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'listar':
                    $tipo = $params['tipo'] ?? 'T';
                    $vigencia = $params['vigencia'] ?? 'T';
                    $result = DB::select('CALL sp16_contratos(?, ?)', [$tipo, $vigencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'excel':
                    // Similar a listar, pero retorna datos para exportar
                    $tipo = $params['tipo'] ?? 'T';
                    $vigencia = $params['vigencia'] ?? 'T';
                    $result = DB::select('CALL sp16_contratos(?, ?)', [$tipo, $vigencia]);
                    // Aquí se puede generar archivo Excel y retornar URL o base64
                    $response['success'] = true;
                    $response['data'] = $result;
                    $response['message'] = 'Exportación Excel generada';
                    break;
                case 'buscar':
                    $contrato = $params['contrato'] ?? null;
                    $tipo = $params['tipo'] ?? 'T';
                    $vigencia = $params['vigencia'] ?? 'T';
                    $result = DB::select('CALL sp16_contratos_buscar(?, ?, ?)', [$contrato, $tipo, $vigencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json(["eResponse" => $response]);
    }
}
