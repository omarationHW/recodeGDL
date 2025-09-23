<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescMultaReqDifTransController extends Controller
{
    // Endpoint único para eRequest/eResponse
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
                case 'buscarFolio':
                    $response['data'] = $this->buscarFolio($params);
                    $response['success'] = true;
                    break;
                case 'buscarDiferencia':
                    $response['data'] = $this->buscarDiferencia($params);
                    $response['success'] = true;
                    break;
                case 'altaDescuento':
                    $response['data'] = $this->altaDescuento($params);
                    $response['success'] = true;
                    break;
                case 'cancelarDescuento':
                    $response['data'] = $this->cancelarDescuento($params);
                    $response['success'] = true;
                    break;
                case 'autorizadores':
                    $response['data'] = $this->autorizadores($params);
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

    private function buscarFolio($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) throw new \Exception('Folio requerido');
        $result = DB::select('SELECT * FROM sp_descmultadiftransm_buscar_folio(?)', [$folio]);
        return $result;
    }

    private function buscarDiferencia($params)
    {
        $folio = $params['folio'] ?? null;
        if (!$folio) throw new \Exception('Folio requerido');
        $result = DB::select('SELECT * FROM sp_descmultadiftransm_buscar_diferencia(?)', [$folio]);
        return $result;
    }

    private function altaDescuento($params)
    {
        $folio = $params['folio'] ?? null;
        $porcentaje = $params['porcentaje'] ?? null;
        $usuario = $params['usuario'] ?? null;
        $autoriza = $params['autoriza'] ?? null;
        $cvedepto = $params['cvedepto'] ?? null;
        if (!$folio || !$porcentaje || !$usuario || !$autoriza || !$cvedepto) {
            throw new \Exception('Parámetros incompletos');
        }
        $result = DB::select('SELECT * FROM sp_descmultadiftransm_alta(?,?,?,?,?)', [
            $folio, $porcentaje, $usuario, $autoriza, $cvedepto
        ]);
        return $result;
    }

    private function cancelarDescuento($params)
    {
        $folio = $params['folio'] ?? null;
        $id_descmulta = $params['id_descmulta'] ?? null;
        $usuario = $params['usuario'] ?? null;
        if (!$folio || !$id_descmulta || !$usuario) {
            throw new \Exception('Parámetros incompletos');
        }
        $result = DB::select('SELECT * FROM sp_descmultadiftransm_cancelar(?,?,?)', [
            $folio, $id_descmulta, $usuario
        ]);
        return $result;
    }

    private function autorizadores($params)
    {
        $usuario = $params['usuario'] ?? null;
        if (!$usuario) throw new \Exception('Usuario requerido');
        $result = DB::select('SELECT * FROM sp_descmultadiftransm_autorizadores(?)', [$usuario]);
        return $result;
    }
}
