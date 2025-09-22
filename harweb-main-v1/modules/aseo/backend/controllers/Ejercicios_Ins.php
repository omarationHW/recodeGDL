<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EjerciciosInsController extends Controller
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
                case 'get_ejercicios':
                    $ejercicios = DB::select('SELECT * FROM ta_16_ejercicios ORDER BY ejercicio');
                    $response['success'] = true;
                    $response['data'] = $ejercicios;
                    break;
                case 'create_ejercicio':
                    $validator = Validator::make($params, [
                        'ejercicio' => 'required|integer|min:1900|max:2100',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $ejercicio = $params['ejercicio'];
                    $exists = DB::selectOne('SELECT 1 FROM ta_16_ejercicios WHERE ejercicio = ?', [$ejercicio]);
                    if ($exists) {
                        $response['message'] = 'YA EXISTE EL EJERCICIO';
                        break;
                    }
                    // Llama al SP
                    $result = DB::select('SELECT sp_create_ejercicio(?) AS result', [$ejercicio]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    $response['message'] = 'Ejercicio creado correctamente';
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
