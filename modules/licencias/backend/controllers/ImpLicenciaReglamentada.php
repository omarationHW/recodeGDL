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
                case 'getLicenciaReglamentada':
                    $licencia = $params['licencia'] ?? null;
                    if (!$licencia) {
                        throw new \Exception('No. de licencia requerido');
                    }
                    // Consulta principal de licencia
                    $licenciaData = DB::selectOne('SELECT * FROM licencias WHERE licencia = ? AND vigente = ? LIMIT 1', [$licencia, 'V']);
                    if (!$licenciaData) {
                        $response['message'] = 'Licencia no encontrada o no vigente';
                        break;
                    }
                    // Consulta giro
                    $giroData = DB::selectOne('SELECT * FROM c_giros WHERE id_giro = ?', [$licenciaData->id_giro]);
                    // Consulta convcta (cve catastral)
                    $convctaData = DB::selectOne('SELECT * FROM convcta WHERE cvecuenta = ?', [$licenciaData->cvecuenta]);
                    // Consulta zona_lic
                    $zonaLicData = DB::selectOne('SELECT * FROM zona_lic WHERE licencia = ?', [$licenciaData->licencia]);
                    $response['success'] = true;
                    $response['data'] = [
                        'licencia' => $licenciaData,
                        'giro' => $giroData,
                        'convcta' => $convctaData,
                        'zona_lic' => $zonaLicData
                    ];
                    break;

                case 'calcAdeudoLicencia':
                    $id_licencia = $params['id_licencia'] ?? null;
                    if (!$id_licencia) {
                        throw new \Exception('id_licencia requerido');
                    }
                    // Ejecutar SP de cálculo de adeudo
                    $result = DB::select('SELECT * FROM calc_adeudolic(?)', [$id_licencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;

                case 'getTmpAdeudoLic':
                    $id_licencia = $params['id_licencia'] ?? null;
                    if (!$id_licencia) {
                        throw new \Exception('id_licencia requerido');
                    }
                    $result = DB::select('SELECT * FROM tmp_adeudolic WHERE id_licencia = ?', [$id_licencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;

                case 'getDetSaldoLic':
                    $id_licencia = $params['id_licencia'] ?? null;
                    if (!$id_licencia) {
                        throw new \Exception('id_licencia requerido');
                    }
                    $result = DB::select('SELECT * FROM detsaldo_licencia(?)', [$id_licencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
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
