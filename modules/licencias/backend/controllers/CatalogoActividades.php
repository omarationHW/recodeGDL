<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class CatalogoActividadesController extends Controller
{
    // Endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o Sanctum
        $response = ["success" => false, "data" => null, "message" => ""];

        try {
            switch ($action) {
                case 'catalogo_actividades.list':
                    $response['data'] = DB::select('SELECT * FROM catalogo_actividades_list(:descripcion)', [
                        'descripcion' => $params['descripcion'] ?? null
                    ]);
                    $response['success'] = true;
                    break;
                case 'catalogo_actividades.get':
                    $response['data'] = DB::select('SELECT * FROM catalogo_actividades_get(:id)', [
                        'id' => $params['id']
                    ]);
                    $response['success'] = true;
                    break;
                case 'catalogo_actividades.create':
                    $result = DB::select('SELECT * FROM catalogo_actividades_create(:id_giro, :descripcion, :observaciones, :vigente, :usuario_alta)', [
                        'id_giro' => $params['id_giro'],
                        'descripcion' => $params['descripcion'],
                        'observaciones' => $params['observaciones'],
                        'vigente' => $params['vigente'],
                        'usuario_alta' => $user ? $user->username : 'api'
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'catalogo_actividades.update':
                    $result = DB::select('SELECT * FROM catalogo_actividades_update(:id, :id_giro, :descripcion, :observaciones, :vigente, :usuario_mod)', [
                        'id' => $params['id'],
                        'id_giro' => $params['id_giro'],
                        'descripcion' => $params['descripcion'],
                        'observaciones' => $params['observaciones'],
                        'vigente' => $params['vigente'],
                        'usuario_mod' => $user ? $user->username : 'api'
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'catalogo_actividades.delete':
                    $result = DB::select('SELECT * FROM catalogo_actividades_delete(:id, :usuario_baja, :motivo_baja)', [
                        'id' => $params['id'],
                        'usuario_baja' => $user ? $user->username : 'api',
                        'motivo_baja' => $params['motivo_baja'] ?? null
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'catalogo_actividades.giros':
                    $response['data'] = DB::select('SELECT * FROM catalogo_giros_list()');
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
