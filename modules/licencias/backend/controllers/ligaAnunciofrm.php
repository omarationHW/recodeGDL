<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LigaAnuncioController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
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
                case 'buscarLicencia':
                    $response = $this->buscarLicencia($params);
                    break;
                case 'buscarEmpresa':
                    $response = $this->buscarEmpresa($params);
                    break;
                case 'buscarAnuncio':
                    $response = $this->buscarAnuncio($params);
                    break;
                case 'ligarAnuncio':
                    $response = $this->ligarAnuncio($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    private function buscarLicencia($params)
    {
        $licencia = $params['licencia'] ?? null;
        if (!$licencia) {
            return ['success' => false, 'message' => 'Licencia requerida'];
        }
        $row = DB::selectOne('SELECT * FROM licencias WHERE licencia = ?', [$licencia]);
        if (!$row) {
            return ['success' => false, 'message' => 'Licencia no encontrada'];
        }
        return ['success' => true, 'data' => $row];
    }

    private function buscarEmpresa($params)
    {
        $empresa = $params['empresa'] ?? null;
        if (!$empresa) {
            return ['success' => false, 'message' => 'Empresa requerida'];
        }
        $row = DB::selectOne('SELECT * FROM licencias WHERE empresa = ?', [$empresa]);
        if (!$row) {
            return ['success' => false, 'message' => 'Empresa no encontrada'];
        }
        return ['success' => true, 'data' => $row];
    }

    private function buscarAnuncio($params)
    {
        $anuncio = $params['anuncio'] ?? null;
        if (!$anuncio) {
            return ['success' => false, 'message' => 'Anuncio requerido'];
        }
        $row = DB::selectOne('SELECT * FROM anuncios WHERE anuncio = ?', [$anuncio]);
        if (!$row) {
            return ['success' => false, 'message' => 'Anuncio no encontrado'];
        }
        return ['success' => true, 'data' => $row];
    }

    private function ligarAnuncio($params)
    {
        $anuncio_id = $params['anuncio_id'] ?? null;
        $licencia_id = $params['licencia_id'] ?? null;
        $empresa_id = $params['empresa_id'] ?? null;
        $isEmpresa = $params['isEmpresa'] ?? false;
        $user = $params['user'] ?? 'sistema';

        if (!$anuncio_id || (!$licencia_id && !$empresa_id)) {
            return ['success' => false, 'message' => 'Datos insuficientes'];
        }

        // Validaciones de vigencia
        $anuncio = DB::selectOne('SELECT * FROM anuncios WHERE id_anuncio = ?', [$anuncio_id]);
        if (!$anuncio) return ['success' => false, 'message' => 'Anuncio no encontrado'];
        if ($anuncio->vigente !== 'V') return ['success' => false, 'message' => 'No se puede ligar un anuncio cancelado.'];

        if ($isEmpresa) {
            $empresa = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$empresa_id]);
            if (!$empresa) return ['success' => false, 'message' => 'Empresa no encontrada'];
            if ($empresa->vigente !== 'V') return ['success' => false, 'message' => 'No se puede ligar a una empresa cancelada.'];
        } else {
            $licencia = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$licencia_id]);
            if (!$licencia) return ['success' => false, 'message' => 'Licencia no encontrada'];
            if ($licencia->vigente !== 'V') return ['success' => false, 'message' => 'No se puede ligar a una licencia cancelada.'];
        }

        // Checa si el anuncio ya está ligado
        if ($anuncio->id_licencia > 0) {
            if (empty($params['confirmar'])) {
                return [
                    'success' => false,
                    'message' => 'El anuncio ya se encuentra ligado a una licencia. ¿Desea continuar?',
                    'require_confirmation' => true
                ];
            }
        }

        DB::beginTransaction();
        try {
            if ($isEmpresa) {
                DB::update('UPDATE anuncios SET id_licencia = ? WHERE id_anuncio = ?', [$empresa_id, $anuncio_id]);
                DB::update('UPDATE detsal_lic SET id_licencia = ? WHERE id_anuncio = ?', [$empresa_id, $anuncio_id]);
                DB::statement('CALL calc_sdosl(?)', [$empresa_id]);
            } else {
                // Actualiza datos de ubicación del anuncio con los de la licencia
                $licencia = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$licencia_id]);
                DB::update('UPDATE anuncios SET id_licencia = ?, zona = ?, subzona = ?, cvecalle = ?, ubicacion = ?, numext_ubic = ?, letraext_ubic = ?, numint_ubic = ?, letraint_ubic = ? WHERE id_anuncio = ?', [
                    $licencia_id,
                    $licencia->zona,
                    $licencia->subzona,
                    $licencia->cvecalle,
                    $licencia->ubicacion,
                    $licencia->numext_ubic,
                    $licencia->letraext_ubic,
                    $licencia->numint_ubic,
                    $licencia->letraint_ubic,
                    $anuncio_id
                ]);
                DB::update('UPDATE detsal_lic SET id_licencia = ? WHERE id_anuncio = ?', [$licencia_id, $anuncio_id]);
                DB::statement('CALL calc_sdosl(?)', [$licencia_id]);
            }
            DB::commit();
            return ['success' => true, 'message' => 'Anuncio ligado correctamente'];
        } catch (\Exception $e) {
            DB::rollBack();
            return ['success' => false, 'message' => 'Error al ligar el anuncio: ' . $e->getMessage()];
        }
    }
}
