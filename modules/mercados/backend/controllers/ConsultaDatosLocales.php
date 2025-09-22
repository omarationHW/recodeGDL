<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsultaDatosLocalesController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
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
                case 'getCatalogos':
                    $response['data'] = [
                        'recaudadoras' => DB::select('SELECT * FROM sp_get_recaudadoras()'),
                        'secciones' => DB::select('SELECT * FROM sp_get_secciones()')
                    ];
                    $response['success'] = true;
                    break;
                case 'buscarLocales':
                    $result = DB::select('SELECT * FROM sp_buscar_locales(?,?,?,?,?,?,?,?)', [
                        $params['oficina'] ?? null,
                        $params['num_mercado'] ?? null,
                        $params['categoria'] ?? null,
                        $params['seccion'] ?? null,
                        $params['local'] ?? null,
                        $params['letra_local'] ?? null,
                        $params['bloque'] ?? null,
                        $params['orden'] ?? 'oficina,num_mercado,categoria,seccion,local,letra_local,bloque'
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'buscarPorNombre':
                    $result = DB::select('SELECT * FROM sp_buscar_locales_nombre(?)', [
                        $params['nombre'] ?? ''
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getMercadosPorOficina':
                    $result = DB::select('SELECT * FROM sp_get_mercados_por_oficina(?)', [
                        $params['oficina']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getLocalIndividual':
                    $result = DB::select('SELECT * FROM sp_get_local_individual(?)', [
                        $params['id_local']
                    ]);
                    $response['data'] = $result;
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
}
