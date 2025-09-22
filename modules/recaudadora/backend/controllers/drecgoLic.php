<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DrecgoLicController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario drecgoLic
     * Entrada: {
     *   "eRequest": {
     *      "action": "string", // e.g. search, alta, baja, consulta, ...
     *      "params": { ... } // parámetros según acción
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];

        try {
            switch ($action) {
                case 'searchLicencia':
                    $folio = $params['folio'] ?? null;
                    $tipo = $params['tipo'] ?? 'L';
                    $result = DB::select('SELECT * FROM sp_busca_licencia(?, ?)', [$folio, $tipo]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'searchAnuncio':
                    $folio = $params['folio'] ?? null;
                    $tipo = $params['tipo'] ?? 'A';
                    $result = DB::select('SELECT * FROM sp_busca_anuncio(?, ?)', [$folio, $tipo]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'buscaDescto':
                    $id_gral = $params['id_gral'] ?? null;
                    $tipo = $params['tipo'] ?? 'L';
                    $result = DB::select('SELECT * FROM sp_busca_descuento(?, ?)', [$id_gral, $tipo]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'altaRecargo':
                    $data = $params;
                    $result = DB::select('SELECT * FROM sp_alta_desc_recargo(?,?,?,?,?,?,?,?)', [
                        $data['tipo'], $data['licencia'], $data['porcentaje'], $data['usuario'], $data['axoini'], $data['axofin'], $data['autoriza'], $data['minmax']
                    ]);
                    $response = ["success" => true, "message" => "Descuento de recargo registrado", "data" => $result];
                    break;
                case 'altaMulta':
                    $data = $params;
                    $result = DB::select('SELECT * FROM sp_alta_desc_multa(?,?,?,?,?,?,?,?)', [
                        $data['tipo'], $data['licencia'], $data['porcentaje'], $data['usuario'], $data['autoriza'], $data['minmax'], $data['axoini'], $data['axofin']
                    ]);
                    $response = ["success" => true, "message" => "Descuento de multa registrado", "data" => $result];
                    break;
                case 'bajaRecargo':
                    $id_descto = $params['id_descto'] ?? null;
                    $usuario = $params['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_baja_desc_recargo(?, ?)', [$id_descto, $usuario]);
                    $response = ["success" => true, "message" => "Descuento de recargo cancelado", "data" => $result];
                    break;
                case 'bajaMulta':
                    $id_descto = $params['id_descto'] ?? null;
                    $usuario = $params['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_baja_desc_multa(?, ?)', [$id_descto, $usuario]);
                    $response = ["success" => true, "message" => "Descuento de multa cancelado", "data" => $result];
                    break;
                case 'consultaPermiso':
                    $usuario = $params['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_consulta_permiso(?)', [$usuario]);
                    $response = ["success" => true, "data" => $result];
                    break;
                case 'consultaFuncionarios':
                    $tipo = $params['tipo'] ?? 'recargo';
                    $result = DB::select('SELECT * FROM sp_consulta_funcionarios(?)', [$tipo]);
                    $response = ["success" => true, "data" => $result];
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida: $action"];
            }
        } catch (\Exception $e) {
            $response = ["success" => false, "message" => $e->getMessage()];
        }
        return response()->json(["eResponse" => $response]);
    }
}
