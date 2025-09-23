<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PagosEspeController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT o Sanctum

        switch ($action) {
            case 'list':
                return $this->list($params);
            case 'authorize':
                return $this->authorizePago($params, $user);
            case 'cancel':
                return $this->cancelPago($params, $user);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada.'
                ], 400);
        }
    }

    /**
     * Listar pagos especiales por cuenta
     */
    public function list($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return response()->json(['success' => false, 'message' => 'cvecuenta requerido'], 400);
        }
        $pagos = DB::select('SELECT * FROM autpagoesp WHERE cvecuenta = ?', [$cvecuenta]);
        return response()->json(['success' => true, 'data' => $pagos]);
    }

    /**
     * Autorizar un pago especial
     */
    public function authorizePago($params, $user)
    {
        $validator = Validator::make($params, [
            'cvecuenta' => 'required|integer',
            'bimini' => 'required|integer|min:1|max:6',
            'axoini' => 'required|integer|min:1900',
            'bimfin' => 'required|integer|min:1|max:6',
            'axofin' => 'required|integer|min:1900',
        ]);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'message' => $validator->errors()->first()], 400);
        }
        // Validación de cuenta activa
        $cuenta = DB::table('convcta')->where('cvecuenta', $params['cvecuenta'])->where('vigente', 'V')->first();
        if (!$cuenta) {
            return response()->json(['success' => false, 'message' => 'No existe una cuenta activa'], 400);
        }
        // Validación de exento/cancelada
        $regprop = DB::table('regprop')->where('cvecuenta', $params['cvecuenta'])->where('exento', 'S')->first();
        if ($regprop) {
            return response()->json(['success' => false, 'message' => 'Cuenta exenta. No puede usar esta opción'], 400);
        }
        if ($cuenta->vigente == 'C') {
            return response()->json(['success' => false, 'message' => 'Cuenta cancelada. No puede usar esta opción'], 400);
        }
        // Validación de registro vigente
        $vigente = DB::table('autpagoesp')
            ->where('cvecuenta', $params['cvecuenta'])
            ->whereNull('cvepago')
            ->first();
        if ($vigente) {
            return response()->json(['success' => false, 'message' => 'Existe un registro para pago especial vigente...'], 400);
        }
        // Insertar autorización
        $id = DB::table('autpagoesp')->insertGetId([
            'bimini' => $params['bimini'],
            'axoini' => $params['axoini'],
            'bimfin' => $params['bimfin'],
            'axofin' => $params['axofin'],
            'fecaut' => now(),
            'autorizo' => $user ? $user->username : 'sistema',
            'cvecuenta' => $params['cvecuenta'],
            'cvepago' => null
        ]);
        return response()->json(['success' => true, 'message' => 'El pago ha sido autorizado...', 'id' => $id]);
    }

    /**
     * Cancelar un pago especial
     */
    public function cancelPago($params, $user)
    {
        $cveaut = $params['cveaut'] ?? null;
        if (!$cveaut) {
            return response()->json(['success' => false, 'message' => 'cveaut requerido'], 400);
        }
        $pago = DB::table('autpagoesp')->where('cveaut', $cveaut)->first();
        if (!$pago) {
            return response()->json(['success' => false, 'message' => 'Registro no encontrado'], 404);
        }
        if ($pago->cvepago == 999999) {
            return response()->json(['success' => false, 'message' => 'El pago autorizado ya está cancelado...'], 400);
        }
        if (!is_null($pago->cvepago) && $pago->cvepago != 999999) {
            return response()->json(['success' => false, 'message' => 'El pago autorizado seleccionado se encuentra pagado, no puedes cancelar...'], 400);
        }
        DB::table('autpagoesp')->where('cveaut', $cveaut)->update([
            'cvepago' => 999999,
            'fecaut' => now(),
            'autorizo' => $user ? $user->username : 'sistema'
        ]);
        return response()->json(['success' => true, 'message' => 'El pago autorizado cancelado...']);
    }
}
