<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RptEmisionEnergiaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'getEmisionEnergia':
                    $response['data'] = $this->getEmisionEnergia($params);
                    $response['success'] = true;
                    break;
                case 'previewEmisionEnergia':
                    $response['data'] = $this->previewEmisionEnergia($params);
                    $response['success'] = true;
                    break;
                case 'printEmisionEnergia':
                    $response['data'] = $this->printEmisionEnergia($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Obtener datos de emisión de energía
     */
    private function getEmisionEnergia($params)
    {
        $validator = Validator::make($params, [
            'oficina' => 'required|integer',
            'mercado' => 'required|integer',
            'axo' => 'required|integer',
            'periodo' => 'required|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('CALL sp_rpt_emision_energia(?, ?, ?, ?)', [
            $params['oficina'],
            $params['mercado'],
            $params['axo'],
            $params['periodo']
        ]);
        return $result;
    }

    /**
     * Previsualizar reporte (puede devolver datos para preview)
     */
    private function previewEmisionEnergia($params)
    {
        // Puede ser igual a getEmisionEnergia, o devolver datos resumidos
        return $this->getEmisionEnergia($params);
    }

    /**
     * Imprimir reporte (puede devolver PDF o trigger de impresión)
     */
    private function printEmisionEnergia($params)
    {
        // Aquí se puede generar un PDF o devolver datos para impresión
        // Ejemplo: llamar un SP que genere el PDF y devuelva la URL
        $result = DB::select('SELECT * FROM sp_rpt_emision_energia_pdf(?, ?, ?, ?)', [
            $params['oficina'],
            $params['mercado'],
            $params['axo'],
            $params['periodo']
        ]);
        return $result;
    }
}
