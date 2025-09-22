<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescMultaTransController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descuentos de multa de transmisión.
     * Entrada: eRequest con action, params, user, etc.
     * Salida: eResponse con status, data, message, errors.
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $user = $input['user'] ?? null;
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => '',
            'errors' => []
        ];

        try {
            switch ($action) {
                case 'searchFolio':
                    $folio = $params['folio'] ?? null;
                    $result = DB::select('SELECT * FROM impuestoTransp WHERE folio = ? AND multaimpuesto > 0 AND (SELECT COALESCE(cvepago,0) FROM actostransm WHERE folio = ?) = 0', [$folio, $folio]);
                    $response['status'] = 'success';
                    $response['data'] = $result;
                    break;
                case 'searchDiferencia':
                    $folio = $params['folio'] ?? null;
                    $result = DB::select('SELECT * FROM Diferencias_glosa i, actostransm a WHERE i.foliot = a.folio AND i.foliot = ? AND recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL)', [$folio]);
                    $response['status'] = 'success';
                    $response['data'] = $result;
                    break;
                case 'getDescuentos':
                    $folio = $params['folio'] ?? null;
                    $result = DB::select('SELECT a.*, b.*, c.descripcion FROM descmultatrans a LEFT JOIN pagos b ON a.cvepago = b.cvepago LEFT JOIN c_autdescmul c ON a.autoriza = c.cveautoriza WHERE a.folio = ? ORDER BY a.id_descmultatrans', [$folio]);
                    $response['status'] = 'success';
                    $response['data'] = $result;
                    break;
                case 'altaDescuento':
                    $folio = $params['folio'];
                    $porcentaje = $params['porcentaje'];
                    $autoriza = $params['autoriza'];
                    $observaciones = $params['observaciones'] ?? '';
                    $usuario = $user['username'] ?? 'system';
                    $id = DB::table('descmultatrans')->insertGetId([
                        'folio' => $folio,
                        'porcentaje' => $porcentaje,
                        'fecalta' => now(),
                        'captalta' => $usuario,
                        'fecbaja' => null,
                        'captbaja' => null,
                        'estado' => 'V',
                        'cvepago' => null,
                        'autoriza' => $autoriza,
                        'observaciones' => $observaciones
                    ]);
                    $response['status'] = 'success';
                    $response['data'] = ['id_descmultatrans' => $id];
                    $response['message'] = 'Descuento registrado correctamente.';
                    break;
                case 'cancelarDescuento':
                    $id = $params['id_descmultatrans'];
                    $folio = $params['folio'];
                    $usuario = $user['username'] ?? 'system';
                    DB::table('descmultatrans')
                        ->where('folio', $folio)
                        ->where('id_descmultatrans', $id)
                        ->update([
                            'estado' => 'C',
                            'fecbaja' => now(),
                            'captbaja' => $usuario
                        ]);
                    $response['status'] = 'success';
                    $response['message'] = 'Descuento cancelado correctamente.';
                    break;
                case 'autorizaList':
                    $usuario = $user['username'] ?? null;
                    $permisos = DB::select('select * from autoriza a,usuarios b,deptos d where a.usuario=? and a.num_tag in(1319,1320) and b.usuario=a.usuario and d.cvedepto=b.cvedepto order by a.num_tag', [$usuario]);
                    if (empty($permisos)) {
                        $result = DB::select('SELECT * FROM c_autdescmul WHERE funcionario = ? AND vigencia = ?', ['N', 'V']);
                    } else {
                        $result = DB::select('SELECT * FROM c_autdescmul WHERE vigencia = ? ORDER BY cveautoriza DESC', ['V']);
                    }
                    $response['status'] = 'success';
                    $response['data'] = $result;
                    break;
                case 'calcDescuento':
                    // Llama stored procedure PostgreSQL
                    $folio = $params['folio'];
                    $opc = $params['opc'];
                    $result = DB::select('CALL calc_desctransmul(?, ?)', [$folio, $opc]);
                    $response['status'] = 'success';
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
            $response['errors'] = [$e->getTraceAsString()];
        }
        return response()->json($response);
    }
}
