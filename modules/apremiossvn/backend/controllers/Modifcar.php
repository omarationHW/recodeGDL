<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ModificarApremioController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre apremios (modificar, consultar, etc.)
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, errors
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'getFolio':
                    $validator = Validator::make($params, [
                        'modulo' => 'required|integer',
                        'folio' => 'required|integer',
                        'recaudadora' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_get_apremio(:modulo, :folio, :recaudadora)', $params);
                    $response['status'] = 'ok';
                    $response['data'] = $data;
                    break;
                case 'modificarFolio':
                    $validator = Validator::make($params, [
                        'id_control' => 'required|integer',
                        'modulo' => 'required|integer',
                        'folio' => 'required|integer',
                        'usuario' => 'required|integer',
                        // ... otros campos requeridos según lógica
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_modificar_apremio(:id_control, :modulo, :folio, :usuario, :params_json)', [
                        'id_control' => $params['id_control'],
                        'modulo' => $params['modulo'],
                        'folio' => $params['folio'],
                        'usuario' => $params['usuario'],
                        'params_json' => json_encode($params)
                    ]);
                    $response['status'] = 'ok';
                    $response['data'] = $result;
                    break;
                case 'historialFolio':
                    $validator = Validator::make($params, [
                        'id_control' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['errors'] = $validator->errors();
                        break;
                    }
                    $data = DB::select('SELECT * FROM sp_historial_apremio(:id_control)', $params);
                    $response['status'] = 'ok';
                    $response['data'] = $data;
                    break;
                default:
                    $response['errors'][] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['errors'][] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
