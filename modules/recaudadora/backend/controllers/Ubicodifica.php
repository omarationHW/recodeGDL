<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class UbicodificaController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asumiendo autenticación JWT

        switch ($action) {
            case 'get_ubicodifica_data':
                return $this->getUbicodificaData($params);
            case 'alta_ubicodifica':
                return $this->altaUbicodifica($params, $user);
            case 'actualiza_ubicodifica':
                return $this->actualizaUbicodifica($params, $user);
            case 'cancela_ubicodifica':
                return $this->cancelaUbicodifica($params, $user);
            case 'listado_ubicodifica':
                return $this->listadoUbicodifica($params);
            default:
                return response()->json(['error' => 'Acción no soportada'], 400);
        }
    }

    /**
     * Obtiene los datos de la cuenta y codificación
     */
    private function getUbicodificaData($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return response()->json(['error' => 'cvecuenta requerido'], 400);
        }
        $datoscont = DB::selectOne('SELECT contrib.nombre_completo as ncompleto, contrib.calle, contrib.noexterior, contrib.interior, catastro.ultcomp, catastro.axoultcomp, c.recaud, c.urbrus, c.cuenta, ub.cvecalle, ub.calle as calleu, ub.noexterior as extu, ub.interior as intu, regprop.cvereg, cal.descripcion FROM catastro, regprop, contrib, convcta c, ubicacion ub LEFT JOIN c_calidpro cal ON cal.cvereg = regprop.cvereg WHERE catastro.cvecuenta = ? AND regprop.cvecuenta = catastro.cvecuenta AND regprop.cveregprop = catastro.cveregprop AND regprop.encabeza = ? AND contrib.cvecont = regprop.cvecont AND c.cvecuenta = catastro.cvecuenta AND ub.cveubic = catastro.cveubic', [$cvecuenta, 'S']);
        $codifica = DB::selectOne('SELECT * FROM ubicacion_req WHERE cvecuenta = ?', [$cvecuenta]);
        return response()->json([
            'datoscont' => $datoscont,
            'codifica' => $codifica
        ]);
    }

    /**
     * Alta de codificación (ubicacion_req)
     */
    private function altaUbicodifica($params, $user)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return response()->json(['error' => 'cvecuenta requerido'], 400);
        }
        $now = now();
        $usuario = $user->username ?? 'sistema';
        $exists = DB::table('ubicacion_req')->where('cvecuenta', $cvecuenta)->exists();
        if ($exists) {
            return response()->json(['error' => 'Ya existe codificación para esta cuenta'], 409);
        }
        $id = DB::table('ubicacion_req')->insertGetId([
            'cvecuenta' => $cvecuenta,
            'fec_alta' => $now,
            'usuario_alta' => $usuario,
            'vigencia' => 'V',
            'fec_mov' => $now,
            'usuario_mov' => $usuario
        ]);
        return response()->json(['success' => true, 'id' => $id]);
    }

    /**
     * Actualiza codificación (reactiva o actualiza)
     */
    private function actualizaUbicodifica($params, $user)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return response()->json(['error' => 'cvecuenta requerido'], 400);
        }
        $now = now();
        $usuario = $user->username ?? 'sistema';
        $codifica = DB::table('ubicacion_req')->where('cvecuenta', $cvecuenta)->first();
        if (!$codifica) {
            return response()->json(['error' => 'No existe codificación para esta cuenta'], 404);
        }
        if ($codifica->vigencia === 'E') {
            return response()->json(['error' => 'Ubicación enviada a corrección en Inconformidades'], 409);
        }
        DB::table('ubicacion_req')->where('cvecuenta', $cvecuenta)->update([
            'fec_alta' => $now,
            'usuario_alta' => $usuario,
            'vigencia' => 'V',
            'fec_mov' => $now,
            'fec_baja' => null,
            'usuario_mov' => $usuario
        ]);
        return response()->json(['success' => true]);
    }

    /**
     * Cancela codificación (baja lógica)
     */
    private function cancelaUbicodifica($params, $user)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return response()->json(['error' => 'cvecuenta requerido'], 400);
        }
        $now = now();
        $usuario = $user->username ?? 'sistema';
        $codifica = DB::table('ubicacion_req')->where('cvecuenta', $cvecuenta)->first();
        if (!$codifica) {
            return response()->json(['error' => 'No existe codificación para esta cuenta'], 404);
        }
        if ($codifica->vigencia === 'E') {
            return response()->json(['error' => 'Ubicación enviada a corrección en Inconformidades'], 409);
        }
        if ($codifica->vigencia === 'C') {
            return response()->json(['error' => 'Ubicación ya está cancelada'], 409);
        }
        DB::table('ubicacion_req')->where('cvecuenta', $cvecuenta)->update([
            'fec_baja' => $now,
            'vigencia' => 'C',
            'fec_mov' => $now,
            'usuario_mov' => $usuario
        ]);
        return response()->json(['success' => true]);
    }

    /**
     * Listado de cuentas sin zona/subzona
     */
    private function listadoUbicodifica($params)
    {
        $reca = $params['reca'] ?? null;
        $ctaini = $params['ctaini'] ?? null;
        $ctafin = $params['ctafin'] ?? null;
        if (!$reca || !$ctaini || !$ctafin) {
            return response()->json(['error' => 'Parámetros requeridos: reca, ctaini, ctafin'], 400);
        }
        $listado = DB::select('SELECT c.recaud, c.urbrus, c.cuenta, c.cvecatnva, u.calle, u.noexterior, u.interior FROM convcta c, catastro ct, ubicacion u WHERE c.recaud = ? AND c.cuenta BETWEEN ? AND ? AND (c.cip [1,3]='   ' OR c.cip IS NULL OR c.cip[1,1]='0') AND ct.cvecuenta=c.cvecuenta AND u.cveubic=ct.cveubic ORDER BY c.recaud, c.cuenta', [$reca, $ctaini, $ctafin]);
        return response()->json(['listado' => $listado]);
    }
}
