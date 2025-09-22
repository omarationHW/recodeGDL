<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EnergiaMttoController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de EnergiaMtto
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'get_catalogs':
                    $response['data'] = [
                        'recaudadoras' => DB::select('SELECT * FROM get_recaudadoras()'),
                        'secciones' => DB::select('SELECT * FROM get_secciones()'),
                        'consumos' => [['value' => 'F', 'label' => 'Precio Fijo / Servicio Normal'], ['value' => 'K', 'label' => 'Precio Kilowhatts / Servicio Medido']]
                    ];
                    $response['success'] = true;
                    break;
                case 'buscar_local':
                    $result = DB::select('SELECT * FROM buscar_local_energia_mtto(?,?,?,?,?,?,?,?)', [
                        $params['oficina'],
                        $params['num_mercado'],
                        $params['categoria'],
                        $params['seccion'],
                        $params['local'],
                        $params['letra_local'],
                        $params['bloque'],
                        $userId
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'alta_energia_mtto':
                    $result = DB::select('SELECT * FROM alta_energia_mtto(?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['id_local'],
                        $params['cve_consumo'],
                        $params['descripcion'],
                        $params['cantidad'],
                        $params['vigencia'],
                        $params['fecha_alta'],
                        $params['axo'],
                        $params['numero'],
                        $params['user_id'],
                        $params['oficina'],
                        $params['num_mercado'],
                        $params['categoria'],
                        $params['seccion']
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'catalog_mercados':
                    $response['data'] = DB::select('SELECT * FROM get_mercados_by_oficina(?)', [$params['oficina']]);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
