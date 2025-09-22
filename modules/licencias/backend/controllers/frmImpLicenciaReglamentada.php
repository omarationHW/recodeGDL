<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ImpLicenciaReglamentadaController extends Controller
{
    /**
     * Handle unified API requests for ImpLicenciaReglamentada.
     * Endpoint: /api/execute
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
                case 'getLicenciasReglamentadas':
                    $result = DB::select('SELECT * FROM sp_get_licencias_reglamentadas()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'createLicenciaReglamentada':
                    $nombre = $params['nombre'] ?? null;
                    $descripcion = $params['descripcion'] ?? null;
                    $usuario_id = $params['usuario_id'] ?? null;
                    $result = DB::select('SELECT * FROM sp_create_licencia_reglamentada(?, ?, ?)', [$nombre, $descripcion, $usuario_id]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'updateLicenciaReglamentada':
                    $id = $params['id'] ?? null;
                    $nombre = $params['nombre'] ?? null;
                    $descripcion = $params['descripcion'] ?? null;
                    $usuario_id = $params['usuario_id'] ?? null;
                    $result = DB::select('SELECT * FROM sp_update_licencia_reglamentada(?, ?, ?, ?)', [$id, $nombre, $descripcion, $usuario_id]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'deleteLicenciaReglamentada':
                    $id = $params['id'] ?? null;
                    $result = DB::select('SELECT * FROM sp_delete_licencia_reglamentada(?)', [$id]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                default:
                    $eResponse['message'] = 'eRequest no reconocido';
            }
        } catch (\Exception $e) {
            Log::error('ImpLicenciaReglamentadaController error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
