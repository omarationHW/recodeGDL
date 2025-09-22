<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests for CRUD operations on c_contribholog.
     * Endpoint: /api/execute
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'get_contribholog_list':
                    $result = DB::select('SELECT * FROM get_contribholog_list()');
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'get_contribholog_by_id':
                    $id = $params['idcontrib'] ?? null;
                    if (!$id) {
                        throw new \Exception('idcontrib is required');
                    }
                    $result = DB::select('SELECT * FROM get_contribholog_by_id(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'insert_contribholog':
                    $validator = Validator::make($params, [
                        'nombre' => 'required|string|max:255',
                        'domicilio' => 'required|string|max:255',
                        'colonia' => 'nullable|string|max:255',
                        'telefono' => 'nullable|string|max:100',
                        'rfc' => 'nullable|string|max:20',
                        'curp' => 'nullable|string|max:20',
                        'email' => 'nullable|email|max:100',
                        'capturista' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception($validator->errors()->first());
                    }
                    $result = DB::select('SELECT * FROM insert_contribholog(?,?,?,?,?,?,?,?)', [
                        $params['nombre'],
                        $params['domicilio'],
                        $params['colonia'] ?? null,
                        $params['telefono'] ?? null,
                        $params['rfc'] ?? null,
                        $params['curp'] ?? null,
                        $params['email'] ?? null,
                        $params['capturista']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    $response['message'] = 'Registro agregado correctamente';
                    break;
                case 'update_contribholog':
                    $validator = Validator::make($params, [
                        'idcontrib' => 'required|integer',
                        'nombre' => 'required|string|max:255',
                        'domicilio' => 'required|string|max:255',
                        'colonia' => 'nullable|string|max:255',
                        'telefono' => 'nullable|string|max:100',
                        'rfc' => 'nullable|string|max:20',
                        'curp' => 'nullable|string|max:20',
                        'email' => 'nullable|email|max:100',
                        'capturista' => 'required|string|max:50'
                    ]);
                    if ($validator->fails()) {
                        throw new \Exception($validator->errors()->first());
                    }
                    $result = DB::select('SELECT * FROM update_contribholog(?,?,?,?,?,?,?,?,?)', [
                        $params['idcontrib'],
                        $params['nombre'],
                        $params['domicilio'],
                        $params['colonia'] ?? null,
                        $params['telefono'] ?? null,
                        $params['rfc'] ?? null,
                        $params['curp'] ?? null,
                        $params['email'] ?? null,
                        $params['capturista']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    $response['message'] = 'Registro actualizado correctamente';
                    break;
                case 'delete_contribholog':
                    $id = $params['idcontrib'] ?? null;
                    if (!$id) {
                        throw new \Exception('idcontrib is required');
                    }
                    $result = DB::select('SELECT * FROM delete_contribholog(?)', [$id]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    $response['message'] = 'Registro eliminado correctamente';
                    break;
                default:
                    throw new \Exception('Operación no soportada');
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}
