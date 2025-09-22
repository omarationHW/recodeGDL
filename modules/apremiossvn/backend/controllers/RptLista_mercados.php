<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     * eRequest: {
     *   action: string,
     *   params: array
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
                case 'RptListaMercados':
                    $result = DB::select('SELECT * FROM rpt_lista_mercados(:vofna, :vmerc1, :vmerc2, :vlocal1, :vlocal2, :vsecc)', [
                        'vofna' => $params['vofna'],
                        'vmerc1' => $params['vmerc1'],
                        'vmerc2' => $params['vmerc2'],
                        'vlocal1' => $params['vlocal1'],
                        'vlocal2' => $params['vlocal2'],
                        'vsecc' => $params['vsecc']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptListaMercadosResumen':
                    $result = DB::select('SELECT * FROM rpt_lista_mercados_resumen(:vofna, :vmerc1, :vmerc2, :vlocal1, :vlocal2, :vsecc)', [
                        'vofna' => $params['vofna'],
                        'vmerc1' => $params['vmerc1'],
                        'vmerc2' => $params['vmerc2'],
                        'vlocal1' => $params['vlocal1'],
                        'vlocal2' => $params['vlocal2'],
                        'vsecc' => $params['vsecc']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptListaMercadosGastos':
                    $result = DB::select('SELECT * FROM rpt_lista_mercados_gastos(:axo, :mes)', [
                        'axo' => $params['axo'],
                        'mes' => $params['mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'RptListaMercadosRecargos':
                    $result = DB::select('SELECT * FROM rpt_lista_mercados_recargos(:axo, :periodo, :vaxo, :vmes, :vdia)', [
                        'axo' => $params['axo'],
                        'periodo' => $params['periodo'],
                        'vaxo' => $params['vaxo'],
                        'vmes' => $params['vmes'],
                        'vdia' => $params['vdia']
                    ]);
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
