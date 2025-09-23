<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescpredController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre descuentos predial.
     * Entrada: eRequest con 'action', 'params', 'user', etc.
     * Salida: eResponse con 'status', 'data', 'message'.
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $user = $input['user'] ?? null;
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'list':
                    $response = $this->listDescpred($params);
                    break;
                case 'get':
                    $response = $this->getDescpred($params);
                    break;
                case 'create':
                    $response = $this->createDescpred($params, $user);
                    break;
                case 'update':
                    $response = $this->updateDescpred($params, $user);
                    break;
                case 'delete':
                    $response = $this->deleteDescpred($params, $user);
                    break;
                case 'reactivate':
                    $response = $this->reactivateDescpred($params, $user);
                    break;
                case 'catalogs':
                    $response = $this->getCatalogs();
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    private function listDescpred($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        $query = "SELECT * FROM sp_descpred_list(:cvecuenta)";
        $data = DB::select($query, ['cvecuenta' => $cvecuenta]);
        return [
            'status' => 'success',
            'data' => $data,
            'message' => 'Listado de descuentos obtenido'
        ];
    }

    private function getDescpred($params)
    {
        $id = $params['id'] ?? null;
        $query = "SELECT * FROM sp_descpred_get(:id)";
        $data = DB::select($query, ['id' => $id]);
        return [
            'status' => 'success',
            'data' => $data[0] ?? null,
            'message' => 'Descuento obtenido'
        ];
    }

    private function createDescpred($params, $user)
    {
        $validator = Validator::make($params, [
            'cvecuenta' => 'required|integer',
            'cvedescuento' => 'required|integer',
            'bimini' => 'required|integer',
            'bimfin' => 'required|integer',
            'solicitante' => 'required|string',
            'identificacion' => 'required|string',
            'fecnac' => 'required|date',
            'institucion' => 'nullable|integer',
            'observaciones' => 'nullable|string',
            'porcentaje' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_descpred_create(?,?,?,?,?,?,?,?,?,?,?)', [
            $params['cvecuenta'],
            $params['cvedescuento'],
            $params['bimini'],
            $params['bimfin'],
            $params['solicitante'],
            $params['identificacion'],
            $params['fecnac'],
            $params['institucion'] ?? null,
            $params['observaciones'] ?? '',
            $params['porcentaje'],
            $user
        ]);
        return [
            'status' => 'success',
            'data' => $result[0] ?? null,
            'message' => 'Descuento creado correctamente'
        ];
    }

    private function updateDescpred($params, $user)
    {
        $validator = Validator::make($params, [
            'id' => 'required|integer',
            'bimini' => 'required|integer',
            'bimfin' => 'required|integer',
            'solicitante' => 'required|string',
            'identificacion' => 'required|string',
            'fecnac' => 'required|date',
            'institucion' => 'nullable|integer',
            'observaciones' => 'nullable|string',
            'porcentaje' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_descpred_update(?,?,?,?,?,?,?,?,?,?)', [
            $params['id'],
            $params['bimini'],
            $params['bimfin'],
            $params['solicitante'],
            $params['identificacion'],
            $params['fecnac'],
            $params['institucion'] ?? null,
            $params['observaciones'] ?? '',
            $params['porcentaje'],
            $user
        ]);
        return [
            'status' => 'success',
            'data' => $result[0] ?? null,
            'message' => 'Descuento actualizado correctamente'
        ];
    }

    private function deleteDescpred($params, $user)
    {
        $id = $params['id'] ?? null;
        $motivo = $params['motivo'] ?? '';
        $result = DB::select('SELECT * FROM sp_descpred_delete(?,?,?)', [
            $id,
            $motivo,
            $user
        ]);
        return [
            'status' => 'success',
            'data' => $result[0] ?? null,
            'message' => 'Descuento dado de baja correctamente'
        ];
    }

    private function reactivateDescpred($params, $user)
    {
        $id = $params['id'] ?? null;
        $result = DB::select('SELECT * FROM sp_descpred_reactivate(?,?)', [
            $id,
            $user
        ]);
        return [
            'status' => 'success',
            'data' => $result[0] ?? null,
            'message' => 'Descuento reactivado correctamente'
        ];
    }

    private function getCatalogs()
    {
        $tipos = DB::select('SELECT * FROM c_descpred ORDER BY axodescto, descripcion');
        $instituciones = DB::select('SELECT * FROM c_instituciones ORDER BY institucion');
        return [
            'status' => 'success',
            'data' => [
                'tipos' => $tipos,
                'instituciones' => $instituciones
            ],
            'message' => 'Catálogos obtenidos'
        ];
    }
}
