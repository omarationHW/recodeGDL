<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AplicaSdosFavorController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'buscarSolicitud':
                    $response['data'] = $this->buscarSolicitud($params);
                    $response['success'] = true;
                    break;
                case 'altaSaldoFavor':
                    $response['data'] = $this->altaSaldoFavor($params);
                    $response['success'] = true;
                    break;
                case 'aplicarSaldoFavor':
                    $response['data'] = $this->aplicarSaldoFavor($params);
                    $response['success'] = true;
                    break;
                case 'modificarSaldoFavor':
                    $response['data'] = $this->modificarSaldoFavor($params);
                    $response['success'] = true;
                    break;
                case 'consultarDetalleSaldos':
                    $response['data'] = $this->consultarDetalleSaldos($params);
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

    private function buscarSolicitud($params)
    {
        $folio = $params['folio'] ?? null;
        $axofol = $params['axofol'] ?? null;
        if (!$folio || !$axofol) {
            throw new \Exception('Folio y año de folio son requeridos');
        }
        $solicitud = DB::selectOne('SELECT * FROM solic_sdosfavor WHERE folio = ? AND axofol = ?', [$folio, $axofol]);
        if (!$solicitud) {
            throw new \Exception('No se encuentra la inconformidad');
        }
        $cuenta = DB::selectOne('SELECT * FROM convcta WHERE cvecuenta = ?', [$solicitud->cvecuenta]);
        $contrib = DB::selectOne('SELECT contrib.nombre_completo as ncompleto, contrib.calle, contrib.noexterior, contrib.interior, catastro.ultcomp, catastro.axoultcomp FROM catastro, regprop, contrib WHERE catastro.cvecuenta = ? AND regprop.cvecuenta = catastro.cvecuenta AND regprop.cveregprop = catastro.cveregprop AND contrib.cvecont = regprop.cvecont AND regprop.encabeza = ?', [$solicitud->cvecuenta, 'S']);
        $sdosFavor = DB::selectOne('SELECT * FROM sdosfavor WHERE id_solic = ?', [$solicitud->id_solic]);
        return [
            'solicitud' => $solicitud,
            'cuenta' => $cuenta,
            'contribuyente' => $contrib,
            'sdosFavor' => $sdosFavor
        ];
    }

    private function altaSaldoFavor($params)
    {
        $id_solic = $params['id_solic'] ?? null;
        $cvecuenta = $params['cvecuenta'] ?? null;
        $importe = $params['importe'] ?? null;
        $usuario = $params['usuario'] ?? null;
        if (!$id_solic || !$cvecuenta || !$importe || !$usuario) {
            throw new \Exception('Datos incompletos para alta de saldo a favor');
        }
        $now = now();
        DB::insert('INSERT INTO sdosfavor (id_solic, cvecuenta, imp_inconform, saldo_favor, fecha_pago, capturista, numpago, imp_pago) VALUES (?, ?, ?, ?, ?, ?, 1, ?)', [$id_solic, $cvecuenta, $importe, $importe, $now, $usuario, $importe]);
        return ['message' => 'Saldo a favor registrado'];
    }

    private function aplicarSaldoFavor($params)
    {
        $id_solic = $params['id_solic'] ?? null;
        $cvecuenta = $params['cvecuenta'] ?? null;
        $bimi = $params['bimi'] ?? null;
        $axoi = $params['axoi'] ?? null;
        $bimf = $params['bimf'] ?? null;
        $axof = $params['axof'] ?? null;
        $importe = $params['importe'] ?? null;
        $usuario = $params['usuario'] ?? null;
        if (!$id_solic || !$cvecuenta || !$bimi || !$axoi || !$bimf || !$axof || !$importe || !$usuario) {
            throw new \Exception('Datos incompletos para aplicar saldo a favor');
        }
        // Lógica principal: llamar SP de afectación y actualizar tablas
        $result = DB::select('SELECT * FROM aplica_saldo_favor(?,?,?,?,?,?,?,?,?)', [
            $id_solic, $cvecuenta, $bimi, $axoi, $bimf, $axof, $importe, $usuario, now()
        ]);
        return $result;
    }

    private function modificarSaldoFavor($params)
    {
        $id_solic = $params['id_solic'] ?? null;
        $importe = $params['importe'] ?? null;
        if (!$id_solic || !$importe) {
            throw new \Exception('Datos incompletos para modificar saldo a favor');
        }
        DB::update('UPDATE sdosfavor SET imp_inconform = ?, saldo_favor = ? WHERE id_solic = ?', [$importe, $importe, $id_solic]);
        return ['message' => 'Saldo a favor modificado'];
    }

    private function consultarDetalleSaldos($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('Cuenta requerida');
        }
        $detalles = DB::select('SELECT * FROM detsaldos WHERE cvecuenta = ? AND saldo > 0 ORDER BY axosal, bimsal ASC', [$cvecuenta]);
        return $detalles;
    }
}
