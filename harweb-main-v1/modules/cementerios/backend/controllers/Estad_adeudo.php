<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EstadAdeudoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'success' => false,
                'data' => null,
                'message' => ''
            ]
        ];

        try {
            switch ($action) {
                case 'getResumen':
                    $response['eResponse']['data'] = $this->getResumen($params);
                    $response['eResponse']['success'] = true;
                    break;
                case 'getListado':
                    $response['eResponse']['data'] = $this->getListado($params);
                    $response['eResponse']['success'] = true;
                    break;
                case 'exportResumenPDF':
                    // Implementar exportación PDF si es necesario
                    $response['eResponse']['message'] = 'Funcionalidad no implementada';
                    break;
                case 'exportListadoPDF':
                    // Implementar exportación PDF si es necesario
                    $response['eResponse']['message'] = 'Funcionalidad no implementada';
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['success'] = false;
            $response['eResponse']['message'] = $e->getMessage();
        }

        return response()->json($response);
    }

    /**
     * Obtiene el resumen de adeudos por cementerio y año
     * @param array $params
     * @return array
     */
    private function getResumen($params)
    {
        $result = DB::select('SELECT * FROM sp_estad_adeudo_resumen()');
        return $result;
    }

    /**
     * Obtiene el listado de adeudos filtrado por años de adeudo
     * @param array $params
     * @return array
     */
    private function getListado($params)
    {
        $validator = Validator::make($params, [
            'axop' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            throw new \Exception('Parámetro axop requerido y debe ser entero');
        }
        $axop = $params['axop'];
        $result = DB::select('SELECT * FROM sp_estad_adeudo_listado(?)', [$axop]);
        return $result;
    }
}
