<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ManntoRecaudadorasController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM ta_16_recaudadoras ORDER BY num_rec');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get':
                    $num_rec = $payload['num_rec'] ?? null;
                    $result = DB::select('SELECT * FROM ta_16_recaudadoras WHERE num_rec = ?', [$num_rec]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'create':
                    $validator = Validator::make($payload, [
                        'num_rec' => 'required|integer',
                        'descripcion' => 'required|string|max:80',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $exists = DB::select('SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = ?', [$payload['num_rec']]);
                    if ($exists) {
                        $response['message'] = 'YA EXISTE o EL CAMPO DE NUMERO ES NULO, INTENTA CON OTRO.';
                        break;
                    }
                    DB::statement('CALL sp_recaudadoras_create(?, ?)', [
                        $payload['num_rec'],
                        $payload['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Recaudadora creada correctamente.';
                    break;
                case 'update':
                    $validator = Validator::make($payload, [
                        'num_rec' => 'required|integer',
                        'descripcion' => 'required|string|max:80',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::statement('CALL sp_recaudadoras_update(?, ?)', [
                        $payload['num_rec'],
                        $payload['descripcion']
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Recaudadora actualizada correctamente.';
                    break;
                case 'delete':
                    $num_rec = $payload['num_rec'] ?? null;
                    // Verificar si existen contratos asociados
                    $contratos = DB::select('SELECT 1 FROM ta_16_contratos WHERE num_rec = ?', [$num_rec]);
                    if ($contratos) {
                        $response['message'] = 'EXISTEN CONTRATOS CON ESTA RECAUDADORA. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA.';
                        break;
                    }
                    DB::statement('CALL sp_recaudadoras_delete(?)', [$num_rec]);
                    $response['success'] = true;
                    $response['message'] = 'Recaudadora eliminada correctamente.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
