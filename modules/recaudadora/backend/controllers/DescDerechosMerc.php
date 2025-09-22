<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescDerechosMercController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getMercados':
                    $response['data'] = DB::select('SELECT * FROM v_mercados WHERE ofna = ?', [$params['recaud']]);
                    $response['success'] = true;
                    break;
                case 'getSecciones':
                    $response['data'] = DB::select('SELECT * FROM v_seccion');
                    $response['success'] = true;
                    break;
                case 'getRecaudadoras':
                    $response['data'] = DB::select('SELECT * FROM c_recaud WHERE recaud < 6');
                    $response['success'] = true;
                    break;
                case 'getLocal':
                    $sql = 'SELECT * FROM v_local WHERE ofna = ? AND num_merc = ? AND categ = ? AND secc = ? AND local = ?';
                    $bindings = [
                        $params['ofna'],
                        $params['num_merc'],
                        $params['categ'],
                        $params['secc'],
                        $params['local']
                    ];
                    if (isset($params['letra']) && $params['letra'] !== '') {
                        $sql .= ' AND letra = ?';
                        $bindings[] = $params['letra'];
                    } else {
                        $sql .= ' AND letra IS NULL';
                    }
                    if (isset($params['bloque']) && $params['bloque'] !== '') {
                        $sql .= ' AND bloque = ?';
                        $bindings[] = $params['bloque'];
                    } else {
                        $sql .= ' AND bloque IS NULL AND substr(minimo,1,4) <= EXTRACT(YEAR FROM CURRENT_DATE)';
                    }
                    $sql .= ' AND (substr(minimo,1,4) < EXTRACT(YEAR FROM CURRENT_DATE) OR (substr(minimo,6,2) <= EXTRACT(MONTH FROM CURRENT_DATE) AND substr(minimo,1,4) = EXTRACT(YEAR FROM CURRENT_DATE)))';
                    $response['data'] = DB::select($sql, $bindings);
                    $response['success'] = true;
                    break;
                case 'getDescuentosMercado':
                    $response['data'] = DB::select('SELECT * FROM ta_11_descderechos WHERE id_local = ?', [$params['id_local']]);
                    $response['success'] = true;
                    break;
                case 'altaDescuentoMercado':
                    $result = DB::select('SELECT * FROM spd_11_descderechosmerc(?,?,?,?,?,?,?,?,?,?)', [
                        $params['par_local'],
                        $params['par_axoi'],
                        $params['par_mesi'],
                        $params['par_axof'],
                        $params['par_mesf'],
                        $user->username,
                        $params['par_porc'],
                        $params['par_autoriza'],
                        1, // par_opc: 1=alta
                        null // control (output)
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'cancelaDescuentoMercado':
                    $result = DB::select('SELECT * FROM spd_11_descderechosmerc(?,?,?,?,?,?,?,?,?,?)', [
                        $params['par_local'],
                        $params['par_axoi'],
                        $params['par_mesi'],
                        $params['par_axof'],
                        $params['par_mesf'],
                        $user->username,
                        $params['par_porc'],
                        $params['par_autoriza'],
                        2, // par_opc: 2=cancela
                        null // control (output)
                    ]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'getPermisosUsuario':
                    $response['data'] = DB::select('SELECT * FROM autoriza WHERE usuario = ? AND num_tag = 1319', [$user->username]);
                    $response['success'] = true;
                    break;
                case 'getFuncionarios':
                    if (isset($params['permiso']) && $params['permiso']) {
                        $response['data'] = DB::select('SELECT cveautoriza,descripcion,nombre,porcentajetope FROM c_autdescrec WHERE vigencia = ? ORDER BY cveautoriza DESC', ['V']);
                    } else {
                        $response['data'] = DB::select('SELECT cveautoriza,descripcion,nombre,porcentajetope FROM c_autdescrec WHERE funcionario = ? AND vigencia = ?', ['N', 'V']);
                    }
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
