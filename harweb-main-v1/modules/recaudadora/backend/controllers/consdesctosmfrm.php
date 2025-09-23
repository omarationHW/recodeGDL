<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ConsDesctosMController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre descuentos de multas municipales.
     * Utiliza el patrón eRequest/eResponse.
     * Endpoint: /api/execute
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'status' => 'error',
            'message' => 'Acción no reconocida',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $eResponse = $this->listDesctos($params);
                    break;
                case 'get':
                    $eResponse = $this->getDescto($params);
                    break;
                case 'create':
                    $eResponse = $this->createDescto($params);
                    break;
                case 'update':
                    $eResponse = $this->updateDescto($params);
                    break;
                case 'delete':
                    $eResponse = $this->deleteDescto($params);
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['status'] = 'error';
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    private function listDesctos($params)
    {
        $id_multa = $params['id_multa'] ?? null;
        if (!$id_multa) {
            return [
                'status' => 'error',
                'message' => 'id_multa es requerido',
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_list_desctos_multa(?)', [$id_multa]);
        return [
            'status' => 'success',
            'message' => 'Descuentos listados',
            'data' => $result
        ];
    }

    private function getDescto($params)
    {
        $folio_descto = $params['folio_descto'] ?? null;
        if (!$folio_descto) {
            return [
                'status' => 'error',
                'message' => 'folio_descto es requerido',
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_get_descto_multa(?)', [$folio_descto]);
        return [
            'status' => 'success',
            'message' => 'Descuento obtenido',
            'data' => $result[0] ?? null
        ];
    }

    private function createDescto($params)
    {
        $validator = Validator::make($params, [
            'id_multa' => 'required|integer',
            'tipo_descto' => 'required|string',
            'valor' => 'required|numeric',
            'autoriza' => 'required|integer',
            'observacion' => 'nullable|string',
            'user_cap' => 'required|string'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_create_descto_multa(?,?,?,?,?,?)', [
            $params['id_multa'],
            $params['tipo_descto'],
            $params['valor'],
            $params['autoriza'],
            $params['observacion'] ?? '',
            $params['user_cap']
        ]);
        return [
            'status' => 'success',
            'message' => 'Descuento creado',
            'data' => $result[0] ?? null
        ];
    }

    private function updateDescto($params)
    {
        $validator = Validator::make($params, [
            'folio_descto' => 'required|integer',
            'tipo_descto' => 'required|string',
            'valor' => 'required|numeric',
            'autoriza' => 'required|integer',
            'observacion' => 'nullable|string',
            'user_cap' => 'required|string'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first(),
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_update_descto_multa(?,?,?,?,?,?)', [
            $params['folio_descto'],
            $params['tipo_descto'],
            $params['valor'],
            $params['autoriza'],
            $params['observacion'] ?? '',
            $params['user_cap']
        ]);
        return [
            'status' => 'success',
            'message' => 'Descuento actualizado',
            'data' => $result[0] ?? null
        ];
    }

    private function deleteDescto($params)
    {
        $folio_descto = $params['folio_descto'] ?? null;
        $user_cap = $params['user_cap'] ?? null;
        if (!$folio_descto || !$user_cap) {
            return [
                'status' => 'error',
                'message' => 'folio_descto y user_cap son requeridos',
                'data' => null
            ];
        }
        $result = DB::select('SELECT * FROM sp_delete_descto_multa(?,?)', [$folio_descto, $user_cap]);
        return [
            'status' => 'success',
            'message' => 'Descuento cancelado',
            'data' => $result[0] ?? null
        ];
    }
}
