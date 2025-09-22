<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class ModlicAdeudoController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $data = $eRequest['data'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = $this->listAdeudos($data);
                    $response['success'] = true;
                    break;
                case 'add':
                    $response['data'] = $this->addAdeudo($data);
                    $response['success'] = true;
                    break;
                case 'edit':
                    $response['data'] = $this->editAdeudo($data);
                    $response['success'] = true;
                    break;
                case 'delete':
                    $response['data'] = $this->deleteAdeudo($data);
                    $response['success'] = true;
                    break;
                case 'get_saldos':
                    $response['data'] = $this->getSaldosLic($data);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }

    private function listAdeudos($data)
    {
        $id_licencia = $data['id_licencia'] ?? null;
        $id_anuncio = $data['id_anuncio'] ?? null;
        if (!$id_licencia || !$id_anuncio) {
            throw new \Exception('Faltan parámetros id_licencia o id_anuncio');
        }
        $adeudos = DB::select('SELECT * FROM detsal_lic WHERE id_licencia = ? AND id_anuncio = ? AND cvepago = 0 ORDER BY axo', [$id_licencia, $id_anuncio]);
        return $adeudos;
    }

    private function addAdeudo($data)
    {
        $validator = Validator::make($data, [
            'id_licencia' => 'required|integer',
            'id_anuncio' => 'required|integer',
            'axo' => 'required|integer|min:1900',
            'derechos' => 'required|numeric',
            'derechos2' => 'nullable|numeric',
            'forma' => 'required|numeric',
            'recargos' => 'nullable|numeric',
            'desc_derechos' => 'nullable|numeric',
            'desc_recargos' => 'nullable|numeric',
            'desc_forma' => 'nullable|numeric',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $data['cvepago'] = 0;
        $data['recargos'] = $data['recargos'] ?? 0;
        $data['desc_derechos'] = $data['desc_derechos'] ?? 0;
        $data['desc_recargos'] = $data['desc_recargos'] ?? 0;
        $data['desc_forma'] = $data['desc_forma'] ?? 0;
        $data['saldo'] = ($data['forma'] ?? 0) + ($data['derechos'] ?? 0) + ($data['derechos2'] ?? 0) + ($data['recargos'] ?? 0);
        $id = DB::table('detsal_lic')->insertGetId([
            'id_licencia' => $data['id_licencia'],
            'id_anuncio' => $data['id_anuncio'],
            'axo' => $data['axo'],
            'derechos' => $data['derechos'],
            'derechos2' => $data['derechos2'] ?? 0,
            'forma' => $data['forma'],
            'recargos' => $data['recargos'],
            'desc_derechos' => $data['desc_derechos'],
            'desc_recargos' => $data['desc_recargos'],
            'desc_forma' => $data['desc_forma'],
            'saldo' => $data['saldo'],
            'cvepago' => 0
        ]);
        // Recalcular saldos
        DB::statement('CALL calc_sdoslsr(?)', [$data['id_licencia']]);
        return ['id' => $id];
    }

    private function editAdeudo($data)
    {
        $validator = Validator::make($data, [
            'id' => 'required|integer',
            'id_licencia' => 'required|integer',
            'id_anuncio' => 'required|integer',
            'axo' => 'required|integer|min:1900',
            'derechos' => 'required|numeric',
            'derechos2' => 'nullable|numeric',
            'forma' => 'required|numeric',
            'recargos' => 'nullable|numeric',
            'desc_derechos' => 'nullable|numeric',
            'desc_recargos' => 'nullable|numeric',
            'desc_forma' => 'nullable|numeric',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $data['saldo'] = ($data['forma'] ?? 0) + ($data['derechos'] ?? 0) + ($data['derechos2'] ?? 0) + ($data['recargos'] ?? 0);
        DB::table('detsal_lic')
            ->where('id', $data['id'])
            ->update([
                'axo' => $data['axo'],
                'derechos' => $data['derechos'],
                'derechos2' => $data['derechos2'] ?? 0,
                'forma' => $data['forma'],
                'recargos' => $data['recargos'] ?? 0,
                'desc_derechos' => $data['desc_derechos'] ?? 0,
                'desc_recargos' => $data['desc_recargos'] ?? 0,
                'desc_forma' => $data['desc_forma'] ?? 0,
                'saldo' => $data['saldo']
            ]);
        // Recalcular saldos
        DB::statement('CALL calc_sdoslsr(?)', [$data['id_licencia']]);
        return ['id' => $data['id']];
    }

    private function deleteAdeudo($data)
    {
        $id = $data['id'] ?? null;
        $id_licencia = $data['id_licencia'] ?? null;
        if (!$id || !$id_licencia) {
            throw new \Exception('Faltan parámetros id o id_licencia');
        }
        DB::table('detsal_lic')->where('id', $id)->delete();
        // Recalcular saldos
        DB::statement('CALL calc_sdoslsr(?)', [$id_licencia]);
        return ['id' => $id];
    }

    private function getSaldosLic($data)
    {
        $id_licencia = $data['id_licencia'] ?? null;
        if (!$id_licencia) {
            throw new \Exception('Falta parámetro id_licencia');
        }
        $saldos = DB::select('SELECT * FROM saldos_lic WHERE id_licencia = ?', [$id_licencia]);
        return $saldos;
    }
}
