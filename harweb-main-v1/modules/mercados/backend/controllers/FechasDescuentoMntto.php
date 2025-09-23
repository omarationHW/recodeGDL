<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FechasDescuentoMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getAll':
                    $result = DB::select('SELECT * FROM fechas_descuento_get_all()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'getByMes':
                    $mes = $data['mes'] ?? null;
                    $result = DB::select('SELECT * FROM fechas_descuento_get_by_mes(?)', [$mes]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'mes' => 'required|integer|min:1|max:12',
                        'fecha_descuento' => 'required|date',
                        'fecha_recargos' => 'required|date',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM fechas_descuento_update(?, ?, ?, ?)', [
                        $data['mes'],
                        $data['fecha_descuento'],
                        $data['fecha_recargos'],
                        $data['id_usuario']
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
