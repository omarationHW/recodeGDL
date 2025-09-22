<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DatosConvenioController extends Controller
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
                case 'getConvenioById':
                    $response['data'] = $this->getConvenioById($params['id_conv']);
                    $response['success'] = true;
                    break;
                case 'getConvenioParciales':
                    $response['data'] = $this->getConvenioParciales($params['id_conv']);
                    $response['success'] = true;
                    break;
                case 'getConvenioResumen':
                    $response['data'] = $this->getConvenioResumen($params['id_conv']);
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
     * Obtiene los datos generales del convenio
     */
    private function getConvenioById($id_conv)
    {
        $result = DB::select('SELECT * FROM sp_get_datos_convenio(?)', [$id_conv]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene las parcialidades del convenio
     */
    private function getConvenioParciales($id_conv)
    {
        return DB::select('SELECT * FROM sp_get_convenio_parciales(?)', [$id_conv]);
    }

    /**
     * Obtiene el resumen del convenio (periodos, estado, etc)
     */
    private function getConvenioResumen($id_conv)
    {
        return DB::select('SELECT * FROM sp_get_convenio_resumen(?)', [$id_conv]);
    }
}
