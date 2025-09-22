<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for GAdeudosGral.
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'GAdeudosGral.getTablas':
                    $data = DB::select('SELECT cve_tab, nombre, descripcion FROM t34_tablas WHERE cve_tab = ?', [$params['par_tab']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'GAdeudosGral.getEtiquetas':
                    $data = DB::select('SELECT * FROM t34_etiq WHERE cve_tab = ?', [$params['par_tab']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'GAdeudosGral.con34_gcont_01':
                    $data = DB::select('CALL con34_gcont_01(?, ?, ?, ?)', [
                        $params['par_tabla'],
                        $params['par_ade'],
                        $params['par_axo'],
                        $params['par_mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'GAdeudosGral.sp34_adeudototal':
                    $data = DB::select('CALL sp34_adeudototal(?, ?)', [
                        $params['par_tabla'],
                        $params['par_fecha']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'GAdeudosGral.exportExcel':
                    // This would trigger a job or return a download link in real implementation
                    $eResponse['success'] = true;
                    $eResponse['data'] = [
                        'url' => '/exports/adeudosgral_' . date('YmdHis') . '.xlsx'
                    ];
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada: ' . $operation;
            }
        } catch (\Exception $e) {
            Log::error('API Execute Error: ' . $e->getMessage());
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
