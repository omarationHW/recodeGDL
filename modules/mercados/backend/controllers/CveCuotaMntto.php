<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CveCuotaMnttoController extends Controller
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
                case 'list_cve_cuota':
                    $result = DB::select('SELECT * FROM ta_11_cve_cuota ORDER BY clave_cuota ASC');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_cve_cuota':
                    $id = $params['clave_cuota'] ?? null;
                    $result = DB::select('SELECT * FROM ta_11_cve_cuota WHERE clave_cuota = ?', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result ? $result[0] : null;
                    break;
                case 'create_cve_cuota':
                    $validator = Validator::make($params, [
                        'clave_cuota' => 'required|integer|min:1',
                        'descripcion' => 'required|string|max:60'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $exists = DB::select('SELECT 1 FROM ta_11_cve_cuota WHERE clave_cuota = ?', [$params['clave_cuota']]);
                    if ($exists) {
                        $response['message'] = 'La clave de cuota ya existe.';
                        break;
                    }
                    DB::statement('CALL sp_cve_cuota_insert(?, ?)', [
                        $params['clave_cuota'],
                        strtoupper($params['descripcion'])
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de cuota creada correctamente.';
                    break;
                case 'update_cve_cuota':
                    $validator = Validator::make($params, [
                        'clave_cuota' => 'required|integer|min:1',
                        'descripcion' => 'required|string|max:60'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::statement('CALL sp_cve_cuota_update(?, ?)', [
                        $params['clave_cuota'],
                        strtoupper($params['descripcion'])
                    ]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de cuota actualizada correctamente.';
                    break;
                case 'delete_cve_cuota':
                    $id = $params['clave_cuota'] ?? null;
                    DB::statement('CALL sp_cve_cuota_delete(?)', [$id]);
                    $response['success'] = true;
                    $response['message'] = 'Clave de cuota eliminada correctamente.';
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
