<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DrecgoTransController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descuentos de recargos en transmisiones.
     * Entrada: eRequest con 'action' y parámetros.
     * Salida: eResponse con datos/resultados.
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user() ? $request->user()->username : ($params['user'] ?? '');
        $response = ["success" => false, "data" => null, "message" => ""];
        try {
            switch ($action) {
                case 'search_folio':
                    $folio = $params['folio'] ?? null;
                    $tipo = $params['tipo'] ?? 'completa';
                    $result = DB::select('SELECT * FROM busca_multa_trans(:folio, :tipo)', [
                        'folio' => $folio,
                        'tipo' => $tipo
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'search_diferencia':
                    $folio = $params['folio'] ?? null;
                    $result = DB::select('SELECT * FROM busca_diferencia_trans(:folio)', [
                        'folio' => $folio
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'alta_descuento':
                    $folio = $params['folio'];
                    $porcentaje = $params['porcentaje'];
                    $observaciones = $params['observaciones'] ?? '';
                    $autoriza = $params['autoriza'];
                    $user = $user;
                    $result = DB::select('SELECT * FROM alta_descuento_trans(:folio, :porcentaje, :observaciones, :autoriza, :user)', [
                        'folio' => $folio,
                        'porcentaje' => $porcentaje,
                        'observaciones' => $observaciones,
                        'autoriza' => $autoriza,
                        'user' => $user
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'cancelar_descuento':
                    $folio = $params['folio'];
                    $id_descto = $params['id_descto'];
                    $user = $user;
                    $result = DB::select('SELECT * FROM cancelar_descuento_trans(:folio, :id_descto, :user)', [
                        'folio' => $folio,
                        'id_descto' => $id_descto,
                        'user' => $user
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_autorizadores':
                    $usuario = $user;
                    $result = DB::select('SELECT * FROM get_autorizadores_trans(:usuario)', [
                        'usuario' => $usuario
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json(["eResponse" => $response]);
    }
}
