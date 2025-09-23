<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class SGCv2Controller extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del sistema SGCv2
     * Entrada: {
     *   "eRequest": {
     *     "action": "string", // nombre de la acción
     *     "params": { ... } // parámetros para la acción
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... } // resultado de la acción
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = null;
        try {
            switch ($action) {
                case 'buscarCuentaCatastral':
                    $eResponse = $this->buscarCuentaCatastral($params);
                    break;
                case 'altaTramiteLicencia':
                    $eResponse = $this->altaTramiteLicencia($params);
                    break;
                case 'consultaLicencia':
                    $eResponse = $this->consultaLicencia($params);
                    break;
                case 'consultaAnuncio':
                    $eResponse = $this->consultaAnuncio($params);
                    break;
                case 'bloquearLicencia':
                    $eResponse = $this->bloquearLicencia($params);
                    break;
                case 'desbloquearLicencia':
                    $eResponse = $this->desbloquearLicencia($params);
                    break;
                case 'bajaLicencia':
                    $eResponse = $this->bajaLicencia($params);
                    break;
                case 'bajaAnuncio':
                    $eResponse = $this->bajaAnuncio($params);
                    break;
                case 'consultaTramite':
                    $eResponse = $this->consultaTramite($params);
                    break;
                // ... otros casos de acciones ...
                default:
                    return response()->json([
                        'eResponse' => [
                            'error' => 'Acción no soportada',
                            'action' => $action
                        ]
                    ], 400);
            }
        } catch (\Exception $ex) {
            Log::error('SGCv2Controller error: ' . $ex->getMessage());
            return response()->json([
                'eResponse' => [
                    'error' => $ex->getMessage()
                ]
            ], 500);
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    private function buscarCuentaCatastral($params)
    {
        $recaud = $params['recaud'] ?? null;
        $urbrus = $params['urbrus'] ?? null;
        $cuenta = $params['cuenta'] ?? null;
        $result = DB::select('SELECT * FROM sp_buscar_cuenta_catastral(?, ?, ?)', [$recaud, $urbrus, $cuenta]);
        return $result[0] ?? null;
    }

    private function altaTramiteLicencia($params)
    {
        $result = DB::select('SELECT * FROM sp_alta_tramite_licencia(?)', [json_encode($params)]);
        return $result[0] ?? null;
    }

    private function consultaLicencia($params)
    {
        $licencia = $params['licencia'] ?? null;
        $result = DB::select('SELECT * FROM sp_consulta_licencia(?)', [$licencia]);
        return $result[0] ?? null;
    }

    private function consultaAnuncio($params)
    {
        $anuncio = $params['anuncio'] ?? null;
        $result = DB::select('SELECT * FROM sp_consulta_anuncio(?)', [$anuncio]);
        return $result[0] ?? null;
    }

    private function bloquearLicencia($params)
    {
        $licencia = $params['licencia'] ?? null;
        $motivo = $params['motivo'] ?? null;
        $usuario = $params['usuario'] ?? null;
        $result = DB::select('SELECT * FROM sp_bloquear_licencia(?, ?, ?)', [$licencia, $motivo, $usuario]);
        return $result[0] ?? null;
    }

    private function desbloquearLicencia($params)
    {
        $licencia = $params['licencia'] ?? null;
        $motivo = $params['motivo'] ?? null;
        $usuario = $params['usuario'] ?? null;
        $result = DB::select('SELECT * FROM sp_desbloquear_licencia(?, ?, ?)', [$licencia, $motivo, $usuario]);
        return $result[0] ?? null;
    }

    private function bajaLicencia($params)
    {
        $licencia = $params['licencia'] ?? null;
        $motivo = $params['motivo'] ?? null;
        $usuario = $params['usuario'] ?? null;
        $result = DB::select('SELECT * FROM sp_baja_licencia(?, ?, ?)', [$licencia, $motivo, $usuario]);
        return $result[0] ?? null;
    }

    private function bajaAnuncio($params)
    {
        $anuncio = $params['anuncio'] ?? null;
        $motivo = $params['motivo'] ?? null;
        $usuario = $params['usuario'] ?? null;
        $result = DB::select('SELECT * FROM sp_baja_anuncio(?, ?, ?)', [$anuncio, $motivo, $usuario]);
        return $result[0] ?? null;
    }

    private function consultaTramite($params)
    {
        $tramite = $params['tramite'] ?? null;
        $result = DB::select('SELECT * FROM sp_consulta_tramite(?)', [$tramite]);
        return $result[0] ?? null;
    }

    // ... otros métodos privados para cada acción ...
}
