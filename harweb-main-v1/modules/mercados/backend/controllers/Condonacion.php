<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CondonacionController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de condonación
     * Entrada: eRequest con action, data
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $userId = auth()->id() ?? 0;
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'buscar_local':
                    $response = $this->buscarLocal($data, $userId);
                    break;
                case 'listar_adeudos':
                    $response = $this->listarAdeudos($data, $userId);
                    break;
                case 'condonar_adeudos':
                    $response = $this->condonarAdeudos($data, $userId);
                    break;
                case 'deshacer_condonacion':
                    $response = $this->deshacerCondonacion($data, $userId);
                    break;
                case 'listar_condonados':
                    $response = $this->listarCondonados($data, $userId);
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

    private function buscarLocal($data, $userId)
    {
        $validator = Validator::make($data, [
            'oficina' => 'required|integer',
            'num_mercado' => 'required|integer',
            'categoria' => 'required|integer',
            'seccion' => 'required|string',
            'local' => 'required|integer',
            'letra_local' => 'nullable|string',
            'bloque' => 'nullable|string'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $params = $validator->validated();
        $local = DB::selectOne('SELECT * FROM buscar_local_condonacion(?,?,?,?,?,?,?)', [
            $params['oficina'],
            $params['num_mercado'],
            $params['categoria'],
            $params['seccion'],
            $params['local'],
            $params['letra_local'],
            $params['bloque']
        ]);
        if (!$local) {
            return [
                'status' => 'error',
                'message' => 'No existe el local digitado'
            ];
        }
        return [
            'status' => 'success',
            'data' => $local,
            'message' => 'Local encontrado'
        ];
    }

    private function listarAdeudos($data, $userId)
    {
        $validator = Validator::make($data, [
            'id_local' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $adeudos = DB::select('SELECT * FROM spd_11_condonacion(?, ?)', [
            $data['id_local'],
            $userId
        ]);
        return [
            'status' => 'success',
            'data' => $adeudos,
            'message' => 'Adeudos listados'
        ];
    }

    private function condonarAdeudos($data, $userId)
    {
        $validator = Validator::make($data, [
            'id_local' => 'required|integer',
            'adeudos' => 'required|array',
            'oficio' => 'required|string',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        DB::beginTransaction();
        try {
            foreach ($data['adeudos'] as $adeudo) {
                DB::statement('SELECT condonar_adeudo_local(?,?,?,?,?,?,?,?)', [
                    $data['id_local'],
                    $adeudo['axo'],
                    $adeudo['periodo'],
                    $adeudo['importe'],
                    'C',
                    'CONDONACION DE ADEUDO OFICIO ' . $data['oficio'],
                    $userId,
                    now()
                ]);
            }
            DB::commit();
            return [
                'status' => 'success',
                'message' => 'Adeudos condonados correctamente'
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    private function deshacerCondonacion($data, $userId)
    {
        $validator = Validator::make($data, [
            'id_local' => 'required|integer',
            'condonados' => 'required|array',
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        DB::beginTransaction();
        try {
            foreach ($data['condonados'] as $cond) {
                DB::statement('SELECT deshacer_condonacion_local(?,?,?,?,?,?,?,?)', [
                    $cond['id_local'],
                    $cond['axo'],
                    $cond['periodo'],
                    $cond['importe'],
                    $userId,
                    now(),
                    $cond['id_cancelacion'],
                    $cond['observacion'] ?? ''
                ]);
            }
            DB::commit();
            return [
                'status' => 'success',
                'message' => 'Condonaciones deshechas correctamente'
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    private function listarCondonados($data, $userId)
    {
        $validator = Validator::make($data, [
            'id_local' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $condonados = DB::select('SELECT * FROM ta_11_ade_loc_canc WHERE id_local = ?', [
            $data['id_local']
        ]);
        return [
            'status' => 'success',
            'data' => $condonados,
            'message' => 'Condonados listados'
        ];
    }
}
