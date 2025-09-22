<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DatosIndividualesController extends Controller
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
                case 'getDatosIndividuales':
                    $response['data'] = $this->getDatosIndividuales($params);
                    $response['success'] = true;
                    break;
                case 'getAdeudos':
                    $response['data'] = $this->getAdeudos($params);
                    $response['success'] = true;
                    break;
                case 'getRequerimientos':
                    $response['data'] = $this->getRequerimientos($params);
                    $response['success'] = true;
                    break;
                case 'getMovimientos':
                    $response['data'] = $this->getMovimientos($params);
                    $response['success'] = true;
                    break;
                case 'getMercado':
                    $response['data'] = $this->getMercado($params);
                    $response['success'] = true;
                    break;
                case 'getCuota':
                    $response['data'] = $this->getCuota($params);
                    $response['success'] = true;
                    break;
                case 'getUsuario':
                    $response['data'] = $this->getUsuario($params);
                    $response['success'] = true;
                    break;
                case 'getTianguis':
                    $response['data'] = $this->getTianguis($params);
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
     * Obtiene los datos individuales del local
     */
    private function getDatosIndividuales($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        $result = DB::select('SELECT * FROM sp_get_datos_individuales(?)', [$id_local]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene los adeudos del local
     */
    private function getAdeudos($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        return DB::select('SELECT * FROM sp_get_adeudos_local(?)', [$id_local]);
    }

    /**
     * Obtiene los requerimientos del local
     */
    private function getRequerimientos($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        return DB::select('SELECT * FROM sp_get_requerimientos_local(?)', [$id_local]);
    }

    /**
     * Obtiene los movimientos del local
     */
    private function getMovimientos($params)
    {
        $id_local = $params['id_local'] ?? null;
        if (!$id_local) {
            throw new \Exception('id_local es requerido');
        }
        return DB::select('SELECT * FROM sp_get_movimientos_local(?)', [$id_local]);
    }

    /**
     * Obtiene los datos del mercado
     */
    private function getMercado($params)
    {
        $oficina = $params['oficina'] ?? null;
        $num_mercado = $params['num_mercado'] ?? null;
        if (!$oficina || !$num_mercado) {
            throw new \Exception('oficina y num_mercado son requeridos');
        }
        return DB::select('SELECT * FROM sp_get_mercado(?, ?)', [$oficina, $num_mercado]);
    }

    /**
     * Obtiene la cuota del local
     */
    private function getCuota($params)
    {
        $axo = $params['axo'] ?? null;
        $categoria = $params['categoria'] ?? null;
        $seccion = $params['seccion'] ?? null;
        $clave_cuota = $params['clave_cuota'] ?? null;
        if (!$axo || !$categoria || !$seccion || !$clave_cuota) {
            throw new \Exception('axo, categoria, seccion y clave_cuota son requeridos');
        }
        return DB::select('SELECT * FROM sp_get_cuota(?, ?, ?, ?)', [$axo, $categoria, $seccion, $clave_cuota]);
    }

    /**
     * Obtiene el usuario
     */
    private function getUsuario($params)
    {
        $id_usuario = $params['id_usuario'] ?? null;
        if (!$id_usuario) {
            throw new \Exception('id_usuario es requerido');
        }
        return DB::select('SELECT * FROM sp_get_usuario(?)', [$id_usuario]);
    }

    /**
     * Obtiene datos de tianguis si aplica
     */
    private function getTianguis($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) {
            throw new \Exception('folio es requerido');
        }
        return DB::select('SELECT * FROM sp_get_tianguis(?)', [$folio]);
    }
}
