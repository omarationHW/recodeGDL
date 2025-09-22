<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RepTiposEmpController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'getTiposEmpReport':
                    $response['data'] = $this->getTiposEmpReport($params);
                    $response['success'] = true;
                    break;
                case 'getTiposEmpOptions':
                    $response['data'] = $this->getTiposEmpOptions();
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
     * Llama al SP de reporte de Tipos de Empresa
     * @param array $params
     * @return array
     */
    private function getTiposEmpReport($params)
    {
        $order = isset($params['order']) ? (int)$params['order'] : 1;
        $result = DB::select('CALL sp_rep_tipos_empresas(?)', [$order]);
        return $result;
    }

    /**
     * Devuelve las opciones de ordenamiento para el frontend
     * @return array
     */
    private function getTiposEmpOptions()
    {
        return [
            ['value' => 1, 'label' => 'Control'],
            ['value' => 2, 'label' => 'Tipo'],
            ['value' => 3, 'label' => 'Descripción']
        ];
    }
}
