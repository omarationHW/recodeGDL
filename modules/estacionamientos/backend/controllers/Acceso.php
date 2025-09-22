<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ExecuteController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del sistema.
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
     *     "params": { ... }
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
        $response = [];

        try {
            switch ($action) {
                case 'login':
                    $response = $this->login($params);
                    break;
                case 'getUserInfo':
                    $response = $this->getUserInfo($params);
                    break;
                case 'getFoliosReport':
                    $response = $this->getFoliosReport($params);
                    break;
                case 'registerFolio':
                    $response = $this->registerFolio($params);
                    break;
                case 'getCatalog':
                    $response = $this->getCatalog($params);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'success' => false,
                        'error' => 'Acción no soportada',
                        'action' => $action
                    ]], 400);
            }
        } catch (\Exception $ex) {
            return response()->json(['eResponse' => [
                'success' => false,
                'error' => $ex->getMessage(),
                'trace' => $ex->getTraceAsString()
            ]], 500);
        }

        return response()->json(['eResponse' => $response]);
    }

    private function login($params)
    {
        $validator = Validator::make($params, [
            'username' => 'required|string',
            'password' => 'required|string',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'error' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM sp_login(:username, :password)', [
            'username' => $params['username'],
            'password' => $params['password']
        ]);
        if (count($result) > 0 && $result[0]->success) {
            return [
                'success' => true,
                'user' => $result[0]
            ];
        } else {
            return [
                'success' => false,
                'error' => $result[0]->error ?? 'Usuario o contraseña incorrectos'
            ];
        }
    }

    private function getUserInfo($params)
    {
        $validator = Validator::make($params, [
            'user_id' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'error' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM sp_get_user_info(:user_id)', [
            'user_id' => $params['user_id']
        ]);
        return [
            'success' => true,
            'user' => $result[0] ?? null
        ];
    }

    private function getFoliosReport($params)
    {
        $validator = Validator::make($params, [
            'year' => 'required|integer',
            'folio' => 'nullable|integer',
            'placa' => 'nullable|string',
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'error' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM sp_get_folios_report(:year, :folio, :placa, :date_from, :date_to)', [
            'year' => $params['year'],
            'folio' => $params['folio'] ?? null,
            'placa' => $params['placa'] ?? null,
            'date_from' => $params['date_from'] ?? null,
            'date_to' => $params['date_to'] ?? null
        ]);
        return [
            'success' => true,
            'folios' => $result
        ];
    }

    private function registerFolio($params)
    {
        $validator = Validator::make($params, [
            'year' => 'required|integer',
            'folio' => 'required|integer',
            'placa' => 'required|string',
            'fecha_folio' => 'required|date',
            'clave' => 'required|integer',
            'estado' => 'required|integer',
            'agente' => 'required|integer',
            'captura' => 'required|integer',
            'zona' => 'required|integer',
            'espacio' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'error' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM sp_register_folio(:year, :folio, :placa, :fecha_folio, :clave, :estado, :agente, :captura, :zona, :espacio)', [
            'year' => $params['year'],
            'folio' => $params['folio'],
            'placa' => $params['placa'],
            'fecha_folio' => $params['fecha_folio'],
            'clave' => $params['clave'],
            'estado' => $params['estado'],
            'agente' => $params['agente'],
            'captura' => $params['captura'],
            'zona' => $params['zona'],
            'espacio' => $params['espacio'],
        ]);
        return [
            'success' => $result[0]->success ?? false,
            'message' => $result[0]->message ?? null
        ];
    }

    private function getCatalog($params)
    {
        $validator = Validator::make($params, [
            'catalog' => 'required|string',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'error' => $validator->errors()->first()
            ];
        }
        $result = DB::select('SELECT * FROM sp_get_catalog(:catalog)', [
            'catalog' => $params['catalog']
        ]);
        return [
            'success' => true,
            'catalog' => $result
        ];
    }
}
