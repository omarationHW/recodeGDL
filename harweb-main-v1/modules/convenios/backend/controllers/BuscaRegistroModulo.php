<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class BuscaRegistroModuloController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con BuscaRegistroModulo
     * Entrada: eRequest con acción y parámetros
     * Salida: eResponse con datos/resultados
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getMercados':
                    $eResponse['data'] = DB::select('SELECT * FROM ta_11_mercados ORDER BY oficina, num_mercado_nvo');
                    $eResponse['success'] = true;
                    break;
                case 'getAseoTipos':
                    $eResponse['data'] = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY tipo_aseo');
                    $eResponse['success'] = true;
                    break;
                case 'getDependencias':
                    $eResponse['data'] = DB::select('SELECT * FROM c_dependencias WHERE tipo IN (\'M\',\'F\') ORDER BY abrevia');
                    $eResponse['success'] = true;
                    break;
                case 'buscarRegistro':
                    $tipo = $params['tipo'] ?? null;
                    $form = $params['form'] ?? [];
                    $result = $this->buscarRegistro($tipo, $form);
                    $eResponse['data'] = $result;
                    $eResponse['success'] = true;
                    break;
                case 'sp_encabezado':
                    $result = DB::select('SELECT * FROM sp_encabezado(:tynInterface, :chSegmento1, :chSegmento2, :chSegmento3, :chSegmento4, :chSegmento5, :chSegmento6)', [
                        'tynInterface' => $params['tynInterface'] ?? 0,
                        'chSegmento1' => $params['chSegmento1'] ?? '',
                        'chSegmento2' => $params['chSegmento2'] ?? '',
                        'chSegmento3' => $params['chSegmento3'] ?? '',
                        'chSegmento4' => $params['chSegmento4'] ?? '',
                        'chSegmento5' => $params['chSegmento5'] ?? '',
                        'chSegmento6' => $params['chSegmento6'] ?? '',
                    ]);
                    $eResponse['data'] = $result;
                    $eResponse['success'] = true;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            Log::error('BuscaRegistroModuloController error: ' . $ex->getMessage());
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }

    /**
     * Lógica para buscar registros según el tipo de formulario
     * @param string $tipo
     * @param array $form
     * @return array
     */
    private function buscarRegistro($tipo, $form)
    {
        switch ($tipo) {
            case 'multas':
                return DB::select('SELECT b.id_multa AS control, a.abrevia, b.axo_acta, b.num_acta, b.contribuyente AS nombre, CONCAT(TRIM(a.abrevia),\'-\',b.axo_acta,\'-\',b.num_acta) AS calcregistro, b.domicilio AS ubicacion FROM c_dependencias a, multas b WHERE a.abrevia = ? AND b.id_dependencia = a.id_dependencia AND b.axo_acta = ? AND b.num_acta = ? AND b.fecha_cancelacion IS NULL', [
                    $form['abrevia'], $form['axo_acta'], $form['num_acta']
                ]);
            case 'lic_construccion':
                // Llama SP de licencias construcción
                return DB::select('SELECT * FROM sp_encabezado(:tynInterface, :chSegmento1, :chSegmento2, :chSegmento3, :chSegmento4, :chSegmento5, :chSegmento6)', [
                    'tynInterface' => 0,
                    'chSegmento1' => $form['segmento1'],
                    'chSegmento2' => $form['segmento2'],
                    'chSegmento3' => $form['segmento3'],
                    'chSegmento4' => ' ',
                    'chSegmento5' => ' ',
                    'chSegmento6' => ' ',
                ]);
            case 'predial':
                return DB::select('SELECT e.cvecuenta AS control, c.nombre_completo AS nombre, CONCAT(e.recaud,\'-\',e.urbrus,\'-\',e.cuenta) AS calcregistro, CONCAT(d.calle, d.noexterior) AS ubicacion FROM convcta e, catastro a, regprop b, contrib c, ubicacion d WHERE e.recaud = ? AND e.urbrus = ? AND e.cuenta = ? AND e.vigente = \"V\" AND a.cvecuenta = e.cvecuenta AND b.cvecuenta = a.cvecuenta AND b.cveregprop = a.cveregprop AND c.cvecont = b.cvecont AND b.encabeza = \"S\" AND d.cvecuenta = e.cvecuenta', [
                    $form['recaud'], $form['urbrus'], $form['cuenta']
                ]);
            case 'lic_giros':
                return DB::select('SELECT id_licencia AS control, licencia, CAST(licencia AS TEXT) AS calcregistro, propietario AS nombre, CONCAT(domicilio,\' Ext. \',numext_prop,\' Int. \',numint_prop) AS ubicacion FROM licencias WHERE licencia = ? AND vigente = \"V\" AND bloqueado = 0', [
                    $form['licencia']
                ]);
            case 'mercados':
                return DB::select('SELECT id_local AS control, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, CONCAT(oficina,\'-\',num_mercado,\'-\',categoria,\'-\',seccion,\'-\',local,\'-\',COALESCE(letra_local,\' \'),\'-\',COALESCE(bloque,\' \')) AS calcregistro, nombre, domicilio AS ubicacion FROM ta_11_locales WHERE oficina = ? AND num_mercado = ? AND categoria = ? AND seccion = ? AND local = ? AND (letra_local = ? OR letra_local IS NULL) AND (bloque = ? OR bloque IS NULL) AND vigencia = \"A\" AND bloqueo = 0', [
                    $form['oficina'], $form['num_mercado'], $form['categoria'], $form['seccion'], $form['local'], $form['letra_local'], $form['bloque']
                ]);
            case 'cementerios':
                return DB::select('SELECT control_rcm AS control, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, CONCAT(cementerio,\'-\',clase,\'-\',COALESCE(clase_alfa,\' \'),\'-\',seccion,\'-\',COALESCE(seccion_alfa,\' \'),\'-\',linea,\'-\',COALESCE(linea_alfa,\' \'),\'-\',fosa,\'-\',COALESCE(fosa_alfa,\' \')) AS calcregistro, nombre, CONCAT(domicilio,\' Ext.\',exterior,\' Int.\',interior) AS ubicacion FROM ta_13_datosrcm WHERE control_rcm = ?', [
                    $form['clase']
                ]);
            case 'aseo':
                return DB::select('SELECT b.control_contrato AS control, b.num_contrato, a.tipo_aseo, CONCAT(b.num_contrato,\'-\',a.tipo_aseo) AS calcregistro, c.descripcion AS nombre, b.domicilio AS ubicacion FROM ta_16_tipo_aseo a, ta_16_contratos b, ta_16_empresas c WHERE a.tipo_aseo = ? AND b.num_contrato = ? AND b.status_vigencia = \"V\" AND b.ctrol_aseo = a.ctrol_aseo AND b.num_empresa = c.num_empresa', [
                    $form['tipo_aseo'], $form['num_contrato']
                ]);
            case 'obras_publicas':
                return DB::select('SELECT id_convenio AS control, colonia, calle, folio, CONCAT(colonia,\'-\',calle,\'-\',folio) AS calcregistro, nombre, CONCAT(desc_calle,\' Ext.\',numero) AS ubicacion FROM ta_17_convenios WHERE colonia = ? AND calle = ? AND folio = ? AND vigencia = \"A\"', [
                    $form['colonia'], $form['calle'], $form['folio']
                ]);
            case 'anuncios':
                return DB::select('SELECT a.id_anuncio AS control, a.anuncio, CAST(a.anuncio AS TEXT) AS calcregistro, b.propietario AS nombre, CONCAT(a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic) AS ubicacion FROM anuncios a, licencias b WHERE a.anuncio = ? AND b.id_licencia = a.id_licencia AND a.vigente = \"V\"', [
                    $form['anuncio']
                ]);
            case 'energia':
                return DB::select('SELECT b.id_energia AS control, CONCAT(a.oficina,\'-\',a.num_mercado,\'-\',a.categoria,\'-\',a.seccion,\'-\',a.local,\'-\',COALESCE(a.letra_local,\' \'),\'-\',COALESCE(a.bloque,\' \')) AS calcregistro, nombre, a.domicilio AS ubicacion FROM ta_11_locales a, ta_11_energia b WHERE a.oficina = ? AND a.num_mercado = ? AND a.categoria = ? AND a.seccion = ? AND a.local = ? AND (a.letra_local = ? OR a.letra_local IS NULL) AND (a.bloque = ? OR a.bloque IS NULL) AND b.id_local = a.id_local AND b.vigencia = \"A\"', [
                    $form['oficina'], $form['num_mercado'], $form['categoria'], $form['seccion'], $form['local'], $form['letra_local'], $form['bloque']
                ]);
            case 'estacionamiento_publico':
                return DB::select('SELECT id AS control, numesta, CAST(numesta AS TEXT) AS calcregistro, nombre, CONCAT(calle, numext) AS ubicacion FROM pubmain WHERE numesta = ?', [
                    $form['numesta']
                ]);
            case 'estacionamiento_exclusivo':
                return DB::select('SELECT a.id AS control, a.no_exclusivo, CAST(a.no_exclusivo AS TEXT) AS calcregistro, b.propietario AS nombre, d.calle AS ubicacion FROM ex_contrato a, ex_propietario b, ex_ubicacion d WHERE a.no_exclusivo = ? AND b.id = a.ex_propietario_id AND d.ex_contrato_id = a.id AND a.estatus = \"V\"', [
                    $form['no_exclusivo']
                ]);
            default:
                return [];
        }
    }
}
