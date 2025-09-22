<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronLocalesController extends Controller
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
                case 'getPadronLocales':
                    $response['data'] = $this->getPadronLocales($params);
                    $response['success'] = true;
                    break;
                case 'exportPadronLocales':
                    $response['data'] = $this->exportPadronLocales($params);
                    $response['success'] = true;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = $this->getRecaudadoras();
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
     * Obtiene el padrón de locales filtrado por recaudadora
     */
    private function getPadronLocales($params)
    {
        $recaudadora = isset($params['recaudadora']) ? (int)$params['recaudadora'] : null;
        if (!$recaudadora) {
            throw new \Exception('Debe especificar la recaudadora');
        }
        $result = DB::select('SELECT * FROM sp_get_padron_locales(?)', [$recaudadora]);
        return $result;
    }

    /**
     * Exporta el padrón de locales a Excel o TXT
     */
    private function exportPadronLocales($params)
    {
        $recaudadora = isset($params['recaudadora']) ? (int)$params['recaudadora'] : null;
        $format = isset($params['format']) ? $params['format'] : 'excel';
        if (!$recaudadora) {
            throw new \Exception('Debe especificar la recaudadora');
        }
        $data = DB::select('SELECT * FROM sp_get_padron_locales(?)', [$recaudadora]);
        // Aquí se puede implementar la lógica de exportación a Excel/TXT
        // Por simplicidad, retornamos los datos crudos
        return [
            'format' => $format,
            'data' => $data
        ];
    }

    /**
     * Obtiene la lista de recaudadoras
     */
    private function getRecaudadoras()
    {
        $result = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
        return $result;
    }
}
