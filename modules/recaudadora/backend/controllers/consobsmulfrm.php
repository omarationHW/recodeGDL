<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsObsMulController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre consobsmulfrm
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        switch ($action) {
            case 'get_observaciones':
                $validator = Validator::make($params, [
                    'id_multa' => 'required|integer',
                ]);
                if ($validator->fails()) {
                    $response['message'] = $validator->errors()->first();
                    break;
                }
                $data = DB::select('SELECT id_multa, observacion, comentario FROM multas WHERE id_multa = ?', [$params['id_multa']]);
                if ($data) {
                    $response['status'] = 'success';
                    $response['data'] = $data[0];
                    $response['message'] = 'Observaciones obtenidas correctamente';
                } else {
                    $response['message'] = 'No se encontró la multa';
                }
                break;

            case 'update_observaciones':
                $validator = Validator::make($params, [
                    'id_multa' => 'required|integer',
                    'observacion' => 'nullable|string',
                    'comentario' => 'nullable|string',
                ]);
                if ($validator->fails()) {
                    $response['message'] = $validator->errors()->first();
                    break;
                }
                $updated = DB::update('UPDATE multas SET observacion = ?, comentario = ? WHERE id_multa = ?', [
                    $params['observacion'] ?? '',
                    $params['comentario'] ?? '',
                    $params['id_multa']
                ]);
                if ($updated) {
                    $response['status'] = 'success';
                    $response['message'] = 'Observaciones actualizadas correctamente';
                } else {
                    $response['message'] = 'No se pudo actualizar la multa';
                }
                break;

            case 'search_multas':
                $validator = Validator::make($params, [
                    'criterio' => 'required|string',
                    'valor' => 'required|string',
                ]);
                if ($validator->fails()) {
                    $response['message'] = $validator->errors()->first();
                    break;
                }
                $allowed = ['contribuyente', 'domicilio', 'num_acta', 'axo_acta'];
                if (!in_array($params['criterio'], $allowed)) {
                    $response['message'] = 'Criterio de búsqueda no permitido';
                    break;
                }
                $sql = "SELECT id_multa, contribuyente, domicilio, axo_acta, num_acta, observacion, comentario FROM multas WHERE ".$params['criterio']." ILIKE ? LIMIT 50";
                $data = DB::select($sql, ['%'.$params['valor'].'%']);
                $response['status'] = 'success';
                $response['data'] = $data;
                $response['message'] = 'Búsqueda realizada';
                break;

            default:
                $response['message'] = 'Acción no soportada';
        }
        return response()->json($response);
    }
}
