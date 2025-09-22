<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class EmpresasContratosController extends Controller
{
    /**
     * Handle unified API requests for Empresas_Contratos
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $eResponse = [
            'status' => 'error',
            'message' => 'Unknown request',
            'data' => null
        ];

        switch ($eRequest) {
            case 'empresas_contratos_list':
                $eResponse = $this->empresasContratosList($params);
                break;
            default:
                $eResponse['message'] = 'Invalid eRequest: ' . $eRequest;
        }
        return response()->json($eResponse);
    }

    /**
     * List Empresas y Contratos por Empresa
     * Params: parOpc, parDescrip, parTipo, parVigencia
     */
    private function empresasContratosList($params)
    {
        $parOpc = $params['parOpc'] ?? 'T';
        $parDescrip = $params['parDescrip'] ?? '';
        $parTipo = $params['parTipo'] ?? 'T';
        $parVigencia = $params['parVigencia'] ?? 'T';

        try {
            $results = DB::select('CALL sp16_empresa_contratos(?, ?, ?, ?)', [
                $parOpc, $parDescrip, $parTipo, $parVigencia
            ]);
            return [
                'status' => 'success',
                'message' => 'Consulta exitosa',
                'data' => $results
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage(),
                'data' => null
            ];
        }
    }
}
