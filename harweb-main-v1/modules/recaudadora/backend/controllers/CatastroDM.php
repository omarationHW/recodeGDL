<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class CatastroDMController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones del sistema CatastroDM
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
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
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];
        try {
            switch ($action) {
                case 'getCuentaByClave':
                    $response['data'] = $this->getCuentaByClave($params);
                    $response['success'] = true;
                    break;
                case 'getAdeudosByCuenta':
                    $response['data'] = $this->getAdeudosByCuenta($params);
                    $response['success'] = true;
                    break;
                case 'insertDescuentoPredial':
                    $response['data'] = $this->insertDescuentoPredial($params);
                    $response['success'] = true;
                    break;
                case 'getDescuentosPredial':
                    $response['data'] = $this->getDescuentosPredial($params);
                    $response['success'] = true;
                    break;
                case 'cancelarDescuentoPredial':
                    $response['data'] = $this->cancelarDescuentoPredial($params);
                    $response['success'] = true;
                    break;
                case 'getUsuarios':
                    $response['data'] = $this->getUsuarios($params);
                    $response['success'] = true;
                    break;
                case 'getCatalogoDescuentos':
                    $response['data'] = $this->getCatalogoDescuentos($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
            Log::error('CatastroDMController error: ' . $e->getMessage());
        }
        return response()->json(['eResponse' => $response]);
    }

    private function getCuentaByClave($params)
    {
        $clave = $params['clave'] ?? null;
        if (!$clave) {
            throw new \Exception('Clave catastral requerida');
        }
        $cuenta = DB::selectOne('SELECT * FROM convcta WHERE cvecatnva = ?', [$clave]);
        return $cuenta;
    }

    private function getAdeudosByCuenta($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('Cuenta requerida');
        }
        $adeudos = DB::select('SELECT * FROM detsaldos WHERE cvecuenta = ? ORDER BY axosal, bimsal', [$cvecuenta]);
        return $adeudos;
    }

    private function insertDescuentoPredial($params)
    {
        $validator = Validator::make($params, [
            'cvecuenta' => 'required|integer',
            'cvedescuento' => 'required|integer',
            'bimini' => 'required|integer',
            'bimfin' => 'required|integer',
            'fecalta' => 'required|date',
            'captalta' => 'required|string',
            'solicitante' => 'required|string',
            'observaciones' => 'nullable|string',
            'recaud' => 'required|integer',
            'foliodesc' => 'required|integer',
            'status' => 'required|string',
            'identificacion' => 'nullable|string',
            'fecnac' => 'nullable|date',
            'institucion' => 'nullable|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $id = DB::table('descpred')->insertGetId([
            'cvecuenta' => $params['cvecuenta'],
            'cvedescuento' => $params['cvedescuento'],
            'bimini' => $params['bimini'],
            'bimfin' => $params['bimfin'],
            'fecalta' => $params['fecalta'],
            'captalta' => $params['captalta'],
            'solicitante' => $params['solicitante'],
            'observaciones' => $params['observaciones'] ?? '',
            'recaud' => $params['recaud'],
            'foliodesc' => $params['foliodesc'],
            'status' => $params['status'],
            'identificacion' => $params['identificacion'] ?? '',
            'fecnac' => $params['fecnac'] ?? null,
            'institucion' => $params['institucion'] ?? null
        ]);
        return ['id' => $id];
    }

    private function getDescuentosPredial($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('Cuenta requerida');
        }
        $descuentos = DB::select('SELECT * FROM descpred WHERE cvecuenta = ? ORDER BY fecalta DESC', [$cvecuenta]);
        return $descuentos;
    }

    private function cancelarDescuentoPredial($params)
    {
        $id = $params['id'] ?? null;
        $usuario = $params['usuario'] ?? null;
        if (!$id || !$usuario) {
            throw new \Exception('ID y usuario requeridos');
        }
        DB::table('descpred')->where('id', $id)->update([
            'status' => 'C',
            'fecbaja' => now(),
            'captbaja' => $usuario
        ]);
        return ['id' => $id, 'status' => 'C'];
    }

    private function getUsuarios($params)
    {
        $usuarios = DB::select('SELECT usuario, nombres, cvedepto FROM usuarios WHERE fecbaj IS NULL');
        return $usuarios;
    }

    private function getCatalogoDescuentos($params)
    {
        $catalogo = DB::select('SELECT * FROM c_descpred WHERE 1=1 ORDER BY descripcion');
        return $catalogo;
    }
}
