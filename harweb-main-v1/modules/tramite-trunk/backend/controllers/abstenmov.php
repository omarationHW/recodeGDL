<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AbstencionMovController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];
        try {
            switch ($action) {
                case 'get_predio_data':
                    $response['data'] = $this->getPredioData($payload);
                    $response['success'] = true;
                    break;
                case 'registrar_abstencion':
                    $response['data'] = $this->registrarAbstencion($payload);
                    $response['success'] = true;
                    $response['message'] = 'Abstención registrada correctamente.';
                    break;
                case 'eliminar_abstencion':
                    $response['data'] = $this->eliminarAbstencion($payload);
                    $response['success'] = true;
                    $response['message'] = 'Abstención eliminada correctamente.';
                    break;
                default:
                    $response['message'] = 'Acción no soportada.';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtener datos del predio y propietario
     */
    private function getPredioData($payload)
    {
        $cvecuenta = $payload['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            throw new \Exception('Falta cvecuenta');
        }
        $predio = DB::selectOne('SELECT * FROM catastro WHERE cvecuenta = ?', [$cvecuenta]);
        $ubicacion = DB::selectOne('SELECT * FROM ubicacion WHERE cvecuenta = ?', [$cvecuenta]);
        $regprop = DB::selectOne('SELECT * FROM regprop WHERE cvecuenta = ? AND vigencia = ? AND encabeza = ?', [$cvecuenta, 'V', 'S']);
        $contrib = null;
        if ($regprop) {
            $contrib = DB::selectOne('SELECT * FROM contrib WHERE cvecont = ?', [$regprop->cvecont]);
        }
        return [
            'predio' => $predio,
            'ubicacion' => $ubicacion,
            'propietario' => $contrib,
            'regprop' => $regprop
        ];
    }

    /**
     * Registrar abstención de movimientos
     */
    private function registrarAbstencion($payload)
    {
        $validator = Validator::make($payload, [
            'cvecuenta' => 'required|integer',
            'axoefec' => 'required|integer|min:1900|max:2100',
            'bimefec' => 'required|integer|min:1|max:6',
            'observacion' => 'required|string',
            'usuario' => 'required|string'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $cvecuenta = $payload['cvecuenta'];
        $axoefec = $payload['axoefec'];
        $bimefec = $payload['bimefec'];
        $observacion = $payload['observacion'];
        $usuario = $payload['usuario'];
        // Validar cuenta activa
        $convcta = DB::selectOne('SELECT * FROM convcta WHERE cvecuenta = ?', [$cvecuenta]);
        if (!$convcta || $convcta->claveutm == '') {
            throw new \Exception('No hay cuenta activa!');
        }
        $catastro = DB::selectOne('SELECT * FROM catastro WHERE cvecuenta = ?', [$cvecuenta]);
        if ($catastro->vigente == 'C') {
            throw new \Exception('Esta cuenta está cancelada, la abstención no es posible!');
        }
        if ($catastro->cvemov == 12) {
            throw new \Exception('Ya existe una abstención activa.');
        }
        // Actualizar catastro
        DB::beginTransaction();
        DB::update('UPDATE catastro SET cvemov = 12, axoefec = ?, bimefec = ?, observacion = ?, feccap = NOW(), capturista = ? WHERE cvecuenta = ?',
            [$axoefec, $bimefec, $observacion, $usuario, $cvecuenta]);
        DB::commit();
        return true;
    }

    /**
     * Eliminar abstención de movimientos
     */
    private function eliminarAbstencion($payload)
    {
        $validator = Validator::make($payload, [
            'cvecuenta' => 'required|integer',
            'axoefec' => 'required|integer|min:1900|max:2100',
            'bimefec' => 'required|integer|min:1|max:6',
            'observacion' => 'required|string',
            'usuario' => 'required|string'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $cvecuenta = $payload['cvecuenta'];
        $axoefec = $payload['axoefec'];
        $bimefec = $payload['bimefec'];
        $observacion = $payload['observacion'];
        $usuario = $payload['usuario'];
        $convcta = DB::selectOne('SELECT * FROM convcta WHERE cvecuenta = ?', [$cvecuenta]);
        if (!$convcta || $convcta->claveutm == '') {
            throw new \Exception('No hay cuenta activa!');
        }
        $catastro = DB::selectOne('SELECT * FROM catastro WHERE cvecuenta = ?', [$cvecuenta]);
        if ($catastro->vigente == 'C') {
            throw new \Exception('Esta cuenta está cancelada, la abstención no es posible!');
        }
        if ($catastro->cvemov != 12) {
            throw new \Exception('No existe abstención activa para eliminar.');
        }
        DB::beginTransaction();
        DB::update('UPDATE catastro SET cvemov = 14, observacion = ?, feccap = NOW(), capturista = ? WHERE cvecuenta = ?',
            [$observacion, $usuario, $cvecuenta]);
        DB::commit();
        return true;
    }
}
