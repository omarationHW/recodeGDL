<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EjecutoresController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre ejecutores
     * Entrada: {
     *   "eRequest": {
     *     "action": "listar|buscar_nombre|buscar_cve",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'listar':
                    // Llama al SP para listar ejecutores activos
                    $result = DB::select('SELECT * FROM sp_ejecutores_listar()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_nombre':
                    $nombre = $params['nombre'] ?? '';
                    $result = DB::select('SELECT * FROM sp_ejecutores_buscar_nombre(?)', [$nombre]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'buscar_cve':
                    $cve_eje = $params['cve_eje'] ?? '';
                    $result = DB::select('SELECT * FROM sp_ejecutores_buscar_cve(?)', [$cve_eje]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
