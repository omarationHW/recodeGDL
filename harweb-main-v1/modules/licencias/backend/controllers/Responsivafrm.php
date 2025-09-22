<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ResponsivaController extends Controller
{
    /**
     * Endpoint único para todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $payload = $input['payload'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'buscarLicencia':
                    $licencia = $payload['licencia'] ?? null;
                    $result = DB::select('SELECT * FROM buscar_licencia_responsiva(?)', [$licencia]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'listarResponsivas':
                    $tipo = $payload['tipo'] ?? 'R';
                    $result = DB::select('SELECT * FROM listar_responsivas(?)', [$tipo]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'crearResponsiva':
                    $data = $payload;
                    $result = DB::select('SELECT * FROM crear_responsiva(?, ?, ?, ?)', [
                        $data['id_licencia'],
                        $data['tipo'],
                        $data['usuario'],
                        $data['observacion'] ?? null
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'cancelarResponsiva':
                    $axo = $payload['axo'];
                    $folio = $payload['folio'];
                    $motivo = $payload['motivo'];
                    $usuario = $payload['usuario'];
                    $result = DB::select('SELECT * FROM cancelar_responsiva(?, ?, ?, ?)', [
                        $axo, $folio, $motivo, $usuario
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'buscarPorFolio':
                    $axo = $payload['axo'] ?? null;
                    $folio = $payload['folio'] ?? null;
                    $tipo = $payload['tipo'] ?? 'R';
                    $result = DB::select('SELECT * FROM buscar_responsiva_folio(?, ?, ?)', [
                        $axo, $folio, $tipo
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'buscarPorLicencia':
                    $licencia = $payload['licencia'] ?? null;
                    $tipo = $payload['tipo'] ?? 'R';
                    $result = DB::select('SELECT * FROM buscar_responsiva_licencia(?, ?)', [
                        $licencia, $tipo
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
        return response()->json($response);
    }
}
