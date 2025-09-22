<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TramiteBajaAnunController extends Controller
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
                case 'buscarAnuncio':
                    $response = $this->buscarAnuncio($params);
                    break;
                case 'tramitarBaja':
                    $response = $this->tramitarBaja($params);
                    break;
                case 'getUltimoFolio':
                    $response = $this->getUltimoFolio($params);
                    break;
                case 'getParametrosLic':
                    $response = $this->getParametrosLic();
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Buscar anuncio por número
     */
    private function buscarAnuncio($params)
    {
        $anuncio = DB::selectOne('SELECT * FROM anuncios WHERE anuncio = ?', [$params['anuncio']]);
        if (!$anuncio) {
            return [
                'success' => false,
                'message' => 'No se encontró el anuncio',
                'data' => null
            ];
        }
        $saldos = DB::select('SELECT * FROM detsal_lic WHERE id_anuncio = ? AND cvepago = 0', [$anuncio->id_anuncio]);
        $licencia = DB::selectOne('SELECT * FROM licencias WHERE id_licencia = ?', [$anuncio->id_licencia]);
        return [
            'success' => true,
            'data' => [
                'anuncio' => $anuncio,
                'saldos' => $saldos,
                'licencia' => $licencia
            ]
        ];
    }

    /**
     * Tramitar baja de anuncio
     */
    private function tramitarBaja($params)
    {
        $validator = Validator::make($params, [
            'anuncio' => 'required|integer',
            'motivo' => 'required|string',
            'usuario' => 'required|string'
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => $validator->errors()->first()
            ];
        }
        $anuncio = DB::selectOne('SELECT * FROM anuncios WHERE anuncio = ?', [$params['anuncio']]);
        if (!$anuncio) {
            return [
                'success' => false,
                'message' => 'No se encontró el anuncio'
            ];
        }
        if ($anuncio->vigente !== 'V') {
            return [
                'success' => false,
                'message' => 'El anuncio ya se encuentra cancelado.'
            ];
        }
        DB::beginTransaction();
        try {
            // Actualizar anuncio
            DB::update('UPDATE anuncios SET vigente = ?, fecha_baja = NOW(), axo_baja = ?, folio_baja = ?, espubic = ? WHERE anuncio = ?', [
                'C',
                $params['axo_baja'] ?? date('Y'),
                $params['folio_baja'] ?? 0,
                $params['motivo'],
                $params['anuncio']
            ]);
            // Cancelar adeudos
            DB::update('UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = ? AND cvepago = 0', [$anuncio->id_anuncio]);
            // Recalcular saldo de la licencia
            DB::statement('CALL calc_sdosl(?)', [$anuncio->id_licencia]);
            // Insertar registro en lic_cancel (folios)
            $folio = DB::selectOne('SELECT COALESCE(MAX(folio),0)+1 as folio FROM lic_cancel WHERE rec = ? AND axo = ?', [$params['rec'] ?? 0, date('Y')]);
            DB::insert('INSERT INTO lic_cancel (rec, axo, folio, licencia, anuncio, motivo, usuario, fecha, imp_solicitud, imp_licencia, importe, cvepago) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?, 0)', [
                $params['rec'] ?? 0,
                date('Y'),
                $folio->folio,
                0,
                $anuncio->anuncio,
                $params['motivo'],
                $params['usuario'],
                $params['imp_solicitud'] ?? 0,
                $params['imp_licencia'] ?? 0,
                $params['importe'] ?? 0
            ]);
            DB::commit();
            return [
                'success' => true,
                'message' => 'Baja tramitada correctamente',
                'data' => null
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }

    /**
     * Obtener último folio
     */
    private function getUltimoFolio($params)
    {
        $folio = DB::selectOne('SELECT rec, axo, COALESCE(MAX(folio),0)+1 as folio FROM lic_cancel WHERE rec = ? AND axo = ? GROUP BY rec, axo', [
            $params['rec'] ?? 0,
            $params['axo'] ?? date('Y')
        ]);
        return [
            'success' => true,
            'data' => $folio
        ];
    }

    /**
     * Obtener parámetros de licencias
     */
    private function getParametrosLic()
    {
        $params = DB::selectOne('SELECT * FROM parametros_lic LIMIT 1');
        return [
            'success' => true,
            'data' => $params
        ];
    }
}
