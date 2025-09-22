<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for Cga_ArcEdoEx.
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
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
                case 'getLastRemesa':
                    $result = DB::select('SELECT COALESCE(MAX(num_remesa), 0) AS last_remesa FROM ta14_bitacora WHERE tipo = ?', ['A']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->last_remesa;
                    break;
                case 'getRemesas':
                    $result = DB::select('SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = ? ORDER BY fecha_fin DESC LIMIT 1', ['A']);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'getRemesaDate':
                    $remesa = $params['remesa'] ?? '';
                    $result = DB::select('SELECT DISTINCT fecharemesa FROM ta14_datos_edo WHERE remesa = ? AND teso_cve IS NULL', [$remesa]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->fecharemesa ?? null;
                    break;
                case 'countRemesaRecords':
                    $remesa = $params['remesa'] ?? '';
                    $result = DB::select('SELECT COUNT(*) AS count FROM ta14_datos_edo WHERE remesa = ?', [$remesa]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0]->count;
                    break;
                case 'insertRemesaRecord':
                    // Params: folio, mpio, tipoact, placa, remesa, fecpago, fecalta, fecremesa, importe
                    $spResult = DB::select('SELECT * FROM sp_insert_ta14_datos_edo(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $params['mpio'],
                        $params['tipoact'],
                        $params['folio'],
                        $params['placa'],
                        $params['fecpago'],
                        $params['importe'],
                        $params['fecalta'],
                        $params['remesa'],
                        $params['fecremesa']
                    ]);
                    $eResponse['success'] = $spResult[0]->success;
                    $eResponse['message'] = $spResult[0]->msg;
                    break;
                case 'applyRemesa':
                    // Params: fecha
                    $spResult = DB::select('SELECT * FROM sp_afec_esta01(?)', [$params['fecha']]);
                    $eResponse['success'] = $spResult[0]->success;
                    $eResponse['message'] = $spResult[0]->msg;
                    break;
                case 'insertBitacora':
                    // Params: fecha_inicio, fecha_fin, fecha, num_remesa, cant_reg
                    $spResult = DB::select('SELECT * FROM sp_insert_ta14_bitacora(?, ?, ?, ?, ?)', [
                        $params['fecha_inicio'],
                        $params['fecha_fin'],
                        $params['fecha'],
                        $params['num_remesa'],
                        $params['cant_reg']
                    ]);
                    $eResponse['success'] = $spResult[0]->success;
                    $eResponse['message'] = $spResult[0]->msg;
                    break;
                default:
                    $eResponse['message'] = 'Invalid action.';
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
