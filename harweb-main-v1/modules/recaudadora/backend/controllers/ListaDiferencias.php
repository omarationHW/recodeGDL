<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'getListaDiferencias':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('SELECT * FROM sp_lista_diferencias(:fecha1, :fecha2, :vigencia)', [
                        $params['fecha1'] ?? null,
                        $params['fecha2'] ?? null,
                        $params['vigencia'] ?? null
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'exportListaDiferenciasExcel':
                    $params = $eRequest['params'] ?? [];
                    $result = DB::select('SELECT * FROM sp_lista_diferencias(:fecha1, :fecha2, :vigencia)', [
                        $params['fecha1'] ?? null,
                        $params['fecha2'] ?? null,
                        $params['vigencia'] ?? null
                    ]);
                    // Aquí deberías generar el archivo Excel y devolver la URL o el archivo
                    // Por simplicidad, devolvemos los datos en crudo
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['error'] = 'Acción no soportada';
                    break;
            }
        } catch (\Exception $ex) {
            Log::error('ExecuteController error: ' . $ex->getMessage());
            $eResponse['error'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
