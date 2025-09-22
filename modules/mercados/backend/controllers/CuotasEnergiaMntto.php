<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CuotasEnergiaMnttoController extends Controller
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
                case 'getCuota':
                    $response['data'] = $this->getCuota($data);
                    $response['success'] = true;
                    break;
                case 'insertCuota':
                    $response['data'] = $this->insertCuota($data);
                    $response['success'] = true;
                    $response['message'] = 'Cuota insertada correctamente.';
                    break;
                case 'updateCuota':
                    $response['data'] = $this->updateCuota($data);
                    $response['success'] = true;
                    $response['message'] = 'Cuota actualizada correctamente.';
                    break;
                case 'listCuotas':
                    $response['data'] = $this->listCuotas($data);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtener una cuota específica
     */
    private function getCuota($data)
    {
        $id = $data['id_kilowhatts'] ?? null;
        if (!$id) {
            throw new \Exception('ID de cuota requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_cuota_energia(?)', [$id]);
        return $result[0] ?? null;
    }

    /**
     * Insertar una nueva cuota
     */
    private function insertCuota($data)
    {
        $validator = Validator::make($data, [
            'axo' => 'required|integer|min:2002',
            'periodo' => 'required|integer|min:1|max:12',
            'importe' => 'required|numeric|min:0.01',
            'id_usuario' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_insert_cuota_energia(?,?,?,?)', [
            $data['axo'],
            $data['periodo'],
            $data['importe'],
            $data['id_usuario']
        ]);
        return $result[0] ?? null;
    }

    /**
     * Actualizar una cuota existente
     */
    private function updateCuota($data)
    {
        $validator = Validator::make($data, [
            'id_kilowhatts' => 'required|integer|min:1',
            'axo' => 'required|integer|min:2002',
            'periodo' => 'required|integer|min:1|max:12',
            'importe' => 'required|numeric|min:0.01',
            'id_usuario' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_update_cuota_energia(?,?,?,?,?)', [
            $data['id_kilowhatts'],
            $data['axo'],
            $data['periodo'],
            $data['importe'],
            $data['id_usuario']
        ]);
        return $result[0] ?? null;
    }

    /**
     * Listar cuotas (opcionalmente por año/periodo)
     */
    private function listCuotas($data)
    {
        $axo = $data['axo'] ?? null;
        $periodo = $data['periodo'] ?? null;
        $result = DB::select('SELECT * FROM sp_list_cuotas_energia(?,?)', [
            $axo, $periodo
        ]);
        return $result;
    }
}
