<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BajaLicenciaController extends Controller
{
    /**
     * Ejecuta acciones sobre baja de licencia vía endpoint unificado.
     * Endpoint: /api/execute
     * Patrón: eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumiendo autenticación JWT

        switch ($action) {
            case 'buscarLicencia':
                return $this->buscarLicencia($params);
            case 'verificarAdeudos':
                return $this->verificarAdeudos($params);
            case 'listarAnunciosLigados':
                return $this->listarAnunciosLigados($params);
            case 'bajaLicencia':
                return $this->bajaLicencia($params, $user);
            case 'obtenerUsuario':
                return $this->obtenerUsuario($user);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ], 400);
        }
    }

    /**
     * Busca licencia por número
     */
    private function buscarLicencia($params)
    {
        $licencia = DB::selectOne('SELECT * FROM licencias WHERE licencia = ?', [$params['licencia']]);
        if (!$licencia) {
            return response()->json(['success' => false, 'message' => 'Licencia no encontrada.']);
        }
        $giro = DB::selectOne('SELECT * FROM c_giros WHERE id_giro = ?', [$licencia->id_giro]);
        return response()->json([
            'success' => true,
            'licencia' => $licencia,
            'giro' => $giro
        ]);
    }

    /**
     * Verifica adeudos de la licencia
     */
    private function verificarAdeudos($params)
    {
        $adeudos = DB::select('SELECT * FROM saldos_lic WHERE id_licencia = ?', [$params['id_licencia']]);
        $total = 0;
        foreach ($adeudos as $a) {
            $total += $a->total;
        }
        return response()->json([
            'success' => true,
            'adeudos' => $adeudos,
            'total' => $total
        ]);
    }

    /**
     * Lista anuncios ligados a la licencia
     */
    private function listarAnunciosLigados($params)
    {
        $anuncios = DB::select('SELECT * FROM anuncios WHERE id_licencia = ? AND vigente = ?', [$params['id_licencia'], 'V']);
        return response()->json([
            'success' => true,
            'anuncios' => $anuncios
        ]);
    }

    /**
     * Realiza la baja de la licencia y sus anuncios ligados
     */
    private function bajaLicencia($params, $user)
    {
        $validator = Validator::make($params, [
            'id_licencia' => 'required|integer',
            'motivo' => 'required|string',
            'anio' => 'required_without:baja_error|integer',
            'folio' => 'required_without:baja_error|integer',
            'baja_error' => 'boolean',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        // Validaciones de negocio
        $licencia = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$params['id_licencia']]);
        if (!$licencia) {
            return response()->json(['success' => false, 'message' => 'Licencia no encontrada.']);
        }
        if ($licencia->vigente != 'V') {
            return response()->json(['success' => false, 'message' => 'La licencia ya está dada de baja o cancelada.']);
        }
        if ($licencia->bloqueado > 0 && $licencia->bloqueado < 5) {
            return response()->json(['success' => false, 'message' => 'La licencia está bloqueada.']);
        }
        // Verificar anuncios bloqueados
        $anuncios = DB::select('SELECT * FROM anuncios WHERE id_licencia = ? AND vigente = ?', [$params['id_licencia'], 'V']);
        foreach ($anuncios as $anuncio) {
            if ($anuncio->bloqueado > 0) {
                return response()->json(['success' => false, 'message' => 'No se puede dar de baja la licencia. El anuncio ' . $anuncio->anuncio . ' está bloqueado.']);
            }
        }

        // Ejecutar SP de baja
        $result = DB::select('SELECT * FROM sp_baja_licencia(?, ?, ?, ?, ?, ?)', [
            $params['id_licencia'],
            $params['motivo'],
            $params['anio'] ?? null,
            $params['folio'] ?? null,
            $params['baja_error'] ?? false,
            $user->username
        ]);
        if ($result && isset($result[0]->success) && $result[0]->success) {
            return response()->json(['success' => true, 'message' => 'Licencia dada de baja correctamente.']);
        } else {
            return response()->json(['success' => false, 'message' => $result[0]->message ?? 'Error al dar de baja la licencia.']);
        }
    }

    /**
     * Obtiene información del usuario autenticado
     */
    private function obtenerUsuario($user)
    {
        return response()->json([
            'success' => true,
            'usuario' => [
                'username' => $user->username,
                'nivel' => $user->nivel,
                'cvedependencia' => $user->cvedependencia
            ]
        ]);
    }
}
