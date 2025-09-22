<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EdoCtaLicenciasController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario EdoCtaLicencias
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|totals|print|cancel|...",
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
                case 'search':
                    $response = $this->search($params);
                    break;
                case 'totals':
                    $response = $this->totals($params);
                    break;
                case 'print':
                    $response = $this->printReport($params);
                    break;
                case 'cancel':
                    $response = $this->cancelDiscount($params);
                    break;
                case 'get_lic_grales':
                    $response = $this->getLicGrales($params);
                    break;
                case 'get_lic_adeudos':
                    $response = $this->getLicAdeudos($params);
                    break;
                case 'get_lic_totales':
                    $response = $this->getLicTotales($params);
                    break;
                case 'odoo_adeudos_detalle_12':
                    $response = $this->getAdeudoDetalle($params);
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }

    private function search($params)
    {
        $tipo = $params['tipo'] ?? 'L';
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            throw new \Exception('Folio requerido');
        }
        if ($tipo === 'L') {
            $result = DB::select('SELECT id_licencia, licencia, (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.saldo>0 AND d.cvepago=0) AS min, (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.saldo>0 AND d.cvepago=0 AND axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max, propietario FROM licencias l, saldos_lic s WHERE l.id_licencia=s.id_licencia AND licencia=? AND s.total>0', [$folio]);
        } else {
            $result = DB::select('SELECT *, (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_anuncio=l.id_anuncio AND d.derechos>0 AND d.cvepago=0) AS min, (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_anuncio=l.id_anuncio AND d.derechos>0 AND d.cvepago=0 AND d.axo<EXTRACT(YEAR FROM CURRENT_DATE)) AS max, (SELECT propietario FROM licencias WHERE id_licencia=l.id_licencia) AS propietario FROM anuncios l, saldos_lic s WHERE l.id_licencia=s.id_licencia AND anuncio=? AND s.anuncios>0', [$folio]);
        }
        return ['data' => $result];
    }

    private function totals($params)
    {
        $tipo = $params['tipo'] ?? 'L';
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            throw new \Exception('Folio requerido');
        }
        $result = DB::select('CALL spget_lic_totales(?, ?)', [$folio, $tipo]);
        return ['data' => $result];
    }

    private function printReport($params)
    {
        // Simulación de impresión, en la práctica se generaría un PDF o similar
        $tipo = $params['tipo'] ?? 'L';
        $folio = $params['folio'] ?? null;
        $user = $params['user'] ?? 'usuario';
        // Lógica de impresión (puede ser llamada a otro SP o generación de PDF)
        return ['message' => 'Reporte generado para folio ' . $folio . ' tipo ' . $tipo . ' por ' . $user];
    }

    private function cancelDiscount($params)
    {
        $id_licencia = $params['id_licencia'] ?? null;
        $id_descto = $params['id_descto'] ?? null;
        $user = $params['user'] ?? 'usuario';
        if (!$id_licencia || !$id_descto) {
            throw new \Exception('Datos incompletos para cancelar');
        }
        DB::update('UPDATE descreclic SET estado = ?, fecbaja = CURRENT_DATE, captbaja = ? WHERE licencia = ? AND id_descto = ?', ['C', $user, $id_licencia, $id_descto]);
        return ['message' => 'Descuento cancelado'];
    }

    private function getLicGrales($params)
    {
        $par_lic = $params['par_lic'] ?? 0;
        $par_anun = $params['par_anun'] ?? 0;
        $par_rec = $params['par_rec'] ?? 1;
        $result = DB::select('CALL spget_lic_grales(?, ?, ?)', [$par_lic, $par_anun, $par_rec]);
        return ['data' => $result];
    }

    private function getLicAdeudos($params)
    {
        $par_id = $params['par_id'] ?? 0;
        $par_tipo = $params['par_tipo'] ?? 'L';
        $result = DB::select('CALL spget_lic_adeudos(?, ?)', [$par_id, $par_tipo]);
        return ['data' => $result];
    }

    private function getLicTotales($params)
    {
        $par_id = $params['par_id'] ?? 0;
        $par_tipo = $params['par_tipo'] ?? 'L';
        $par_no = $params['par_no'] ?? 'S';
        $result = DB::select('CALL spget_lic_totales(?, ?, ?)', [$par_id, $par_tipo, $par_no]);
        return ['data' => $result];
    }

    private function getAdeudoDetalle($params)
    {
        $p_tipo = $params['p_tipo'] ?? 'L';
        $p_numero = $params['p_numero'] ?? 0;
        $p_rec = $params['p_rec'] ?? 100;
        $p_forma_pago = $params['p_forma_pago'] ?? ' ';
        $p_identificador = $params['p_identificador'] ?? 0;
        $result = DB::select('CALL odoo_adeudos_detalle_12(?, ?, ?, ?, ?)', [$p_tipo, $p_numero, $p_rec, $p_forma_pago, $p_identificador]);
        return ['data' => $result];
    }
}
