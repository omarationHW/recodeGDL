<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PrescripcionController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de Prescripción.
     * Entrada: eRequest con action, data, user, etc.
     * Salida: eResponse con status, data, message, etc.
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $data = $eRequest['data'] ?? [];
        $user = $eRequest['user'] ?? null;
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'buscar_local':
                    $response = $this->buscarLocal($data);
                    break;
                case 'listar_adeudos':
                    $response = $this->listarAdeudos($data);
                    break;
                case 'listar_prescripcion':
                    $response = $this->listarPrescripcion($data);
                    break;
                case 'prescribir_adeudos':
                    $response = $this->prescribirAdeudos($data, $user);
                    break;
                case 'quitar_prescripcion':
                    $response = $this->quitarPrescripcion($data, $user);
                    break;
                case 'catalogo_mercados':
                    $response = $this->catalogoMercados();
                    break;
                case 'catalogo_secciones':
                    $response = $this->catalogoSecciones();
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }

    private function buscarLocal($data)
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
        $local = DB::selectOne('select a.id_local, b.id_energia, a.nombre, b.local_adicional from ta_11_locales a join ta_11_energia b on a.id_local = b.id_local where a.oficina = ? and a.num_mercado = ? and a.categoria = ? and a.seccion = ? and a.local = ? and a.vigencia = ? and a.bloqueo < 4' .
            (empty($params['letra_local']) ? ' and a.letra_local is null' : ' and a.letra_local = ?') .
            (empty($params['bloque']) ? ' and a.bloque is null' : ' and a.bloque = ?'),
            array_values(array_filter([
                $params['oficina'],
                $params['num_mercado'],
                $params['categoria'],
                $params['seccion'],
                $params['local'],
                'A',
                $params['letra_local'] ?? null,
                $params['bloque'] ?? null
            ], function($v) { return $v !== null; }))
        );
        if (!$local) {
            return [
                'status' => 'error',
                'message' => 'No existe el local o está dado de baja.'
            ];
        }
        return [
            'status' => 'success',
            'data' => $local,
            'message' => 'Local encontrado.'
        ];
    }

    private function listarAdeudos($data)
    {
        $validator = Validator::make($data, [
            'id_energia' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $adeudos = DB::select('select * from ta_11_adeudo_energ where id_energia = ? order by axo, periodo', [$data['id_energia']]);
        return [
            'status' => 'success',
            'data' => $adeudos,
            'message' => 'Adeudos listados.'
        ];
    }

    private function listarPrescripcion($data)
    {
        $validator = Validator::make($data, [
            'id_energia' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $prescripcion = DB::select('select * from ta_11_ade_ene_canc where id_energia = ? order by axo, periodo', [$data['id_energia']]);
        return [
            'status' => 'success',
            'data' => $prescripcion,
            'message' => 'Prescripción listada.'
        ];
    }

    private function prescribirAdeudos($data, $user)
    {
        $validator = Validator::make($data, [
            'id_energia' => 'required|integer',
            'adeudos' => 'required|array',
            'oficio' => 'required|string',
            'movimiento' => 'required|string' // 'Prescripcion' o 'Condonacion'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $adeudos = $data['adeudos'];
        $oficio = $data['oficio'];
        $mov = strtoupper(substr($data['movimiento'], 0, 1)); // P o C
        $obs = ($mov == 'P' ? 'PRESCRIPCION DE ADEUDO OFICIO ' : 'CONDONACION DE ADEUDO OFICIO ') . $oficio;
        DB::beginTransaction();
        try {
            foreach ($adeudos as $ad) {
                DB::statement('select sp_prescribir_adeudo(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $ad['id_energia'],
                    $ad['axo'],
                    $ad['periodo'],
                    $ad['cve_consumo'],
                    $ad['cantidad'],
                    $ad['importe'],
                    $mov,
                    $obs,
                    $user['id']
                ]);
            }
            DB::commit();
            return [
                'status' => 'success',
                'message' => 'Adeudos prescriptos correctamente.'
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    private function quitarPrescripcion($data, $user)
    {
        $validator = Validator::make($data, [
            'id_energia' => 'required|integer',
            'prescripciones' => 'required|array'
        ]);
        if ($validator->fails()) {
            return [
                'status' => 'error',
                'message' => $validator->errors()->first()
            ];
        }
        $prescripciones = $data['prescripciones'];
        DB::beginTransaction();
        try {
            foreach ($prescripciones as $pr) {
                DB::statement('select sp_quitar_prescripcion(?, ?, ?, ?, ?, ?, ?, ?)', [
                    $pr['id_energia'],
                    $pr['axo'],
                    $pr['periodo'],
                    $pr['cve_consumo'],
                    $pr['cantidad'],
                    $pr['importe'],
                    $user['id'],
                    $pr['id_cancelacion']
                ]);
            }
            DB::commit();
            return [
                'status' => 'success',
                'message' => 'Prescripción quitada y adeudo restaurado.'
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    private function catalogoMercados()
    {
        $mercados = DB::select('select * from ta_11_mercados where cuenta_energia > 0 order by oficina, num_mercado_nvo');
        return [
            'status' => 'success',
            'data' => $mercados
        ];
    }

    private function catalogoSecciones()
    {
        $secciones = DB::select('select seccion from ta_11_secciones order by seccion');
        return [
            'status' => 'success',
            'data' => $secciones
        ];
    }
}
