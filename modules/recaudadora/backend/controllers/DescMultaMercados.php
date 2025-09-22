<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescMultaMercadosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descuentos de multas de mercados.
     * Entrada: eRequest con acción, parámetros y usuario.
     * Salida: eResponse con status, mensaje y datos.
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['eRequest']['action'] ?? null;
        $params = $input['eRequest']['params'] ?? [];
        $user = $input['eRequest']['user'] ?? null;
        $response = [
            'status' => 'error',
            'message' => 'Acción no válida',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'searchLocal':
                    $response = $this->searchLocal($params);
                    break;
                case 'getDiscounts':
                    $response = $this->getDiscounts($params);
                    break;
                case 'createDiscount':
                    $response = $this->createDiscount($params, $user);
                    break;
                case 'cancelDiscount':
                    $response = $this->cancelDiscount($params, $user);
                    break;
                case 'getRecaudadoras':
                    $response = $this->getRecaudadoras();
                    break;
                case 'getMercados':
                    $response = $this->getMercados($params);
                    break;
                case 'getSecciones':
                    $response = $this->getSecciones();
                    break;
                case 'getFuncionarios':
                    $response = $this->getFuncionarios();
                    break;
                default:
                    $response = [
                        'status' => 'error',
                        'message' => 'Acción no reconocida',
                        'data' => null
                    ];
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'message' => $e->getMessage(),
                'data' => null
            ];
        }
        return response()->json(['eResponse' => $response]);
    }

    private function searchLocal($params)
    {
        // Busca local en v_local según parámetros
        $sql = "SELECT * FROM v_local WHERE ofna = :ofna AND num_merc = :num_merc AND categ = :categ AND secc = :secc AND local = :local";
        $bindings = [
            'ofna' => $params['ofna'],
            'num_merc' => $params['num_merc'],
            'categ' => $params['categ'],
            'secc' => $params['secc'],
            'local' => $params['local']
        ];
        if (!empty($params['letra'])) {
            $sql .= " AND letra = :letra";
            $bindings['letra'] = $params['letra'];
        } else {
            $sql .= " AND letra IS NULL";
        }
        if (!empty($params['bloque'])) {
            $sql .= " AND bloque = :bloque";
            $bindings['bloque'] = $params['bloque'];
        } else {
            $sql .= " AND bloque IS NULL";
        }
        $local = DB::connection('pgsql')->select($sql, $bindings);
        if (empty($local)) {
            return [
                'status' => 'error',
                'message' => 'Local no existe, está dado de baja o sin adeudo vencido',
                'data' => null
            ];
        }
        return [
            'status' => 'success',
            'message' => 'Local encontrado',
            'data' => $local[0]
        ];
    }

    private function getDiscounts($params)
    {
        // Trae descuentos vigentes para un local
        $sql = "SELECT * FROM ta_11_descmulta WHERE id_local = :id_local ORDER BY fecha_alta DESC";
        $discounts = DB::connection('pgsql')->select($sql, ['id_local' => $params['id_local']]);
        return [
            'status' => 'success',
            'message' => 'Descuentos encontrados',
            'data' => $discounts
        ];
    }

    private function createDiscount($params, $user)
    {
        // Valida porcentaje
        $funcionario = DB::connection('pgsql')->selectOne("SELECT * FROM c_autdescmul WHERE cveautoriza = :autoriza", ['autoriza' => $params['autoriza']]);
        if (!$funcionario) {
            return [
                'status' => 'error',
                'message' => 'Funcionario no autorizado',
                'data' => null
            ];
        }
        if ($params['porcentaje'] > $funcionario->porcentajetope) {
            return [
                'status' => 'error',
                'message' => 'Porcentaje de descuento mayor al permitido',
                'data' => null
            ];
        }
        // Llama SP
        $result = DB::connection('pgsql')->select('SELECT * FROM spd_11_descmultamerc(:par_local, :par_axoi, :par_mesi, :par_axof, :par_mesf, :par_usuario, :par_porc, :par_autoriza, :par_opc)', [
            'par_local' => $params['id_local'],
            'par_axoi' => $params['axoi'],
            'par_mesi' => $params['mesi'],
            'par_axof' => $params['axof'],
            'par_mesf' => $params['mesf'],
            'par_usuario' => $user,
            'par_porc' => $params['porcentaje'],
            'par_autoriza' => $params['autoriza'],
            'par_opc' => 1
        ]);
        return [
            'status' => 'success',
            'message' => 'Descuento registrado',
            'data' => $result
        ];
    }

    private function cancelDiscount($params, $user)
    {
        // Llama SP para cancelar
        $result = DB::connection('pgsql')->select('SELECT * FROM spd_11_descmultamerc(:par_local, :par_axoi, :par_mesi, :par_axof, :par_mesf, :par_usuario, :par_porc, :par_autoriza, :par_opc)', [
            'par_local' => $params['id_local'],
            'par_axoi' => $params['axoi'],
            'par_mesi' => $params['mesi'],
            'par_axof' => $params['axof'],
            'par_mesf' => $params['mesf'],
            'par_usuario' => $user,
            'par_porc' => $params['porcentaje'],
            'par_autoriza' => $params['autoriza'],
            'par_opc' => 2
        ]);
        return [
            'status' => 'success',
            'message' => 'Descuento cancelado',
            'data' => $result
        ];
    }

    private function getRecaudadoras()
    {
        $recs = DB::connection('pgsql')->select('SELECT * FROM c_recaud WHERE recaud < 6');
        return [
            'status' => 'success',
            'message' => 'Recaudadoras encontradas',
            'data' => $recs
        ];
    }

    private function getMercados($params)
    {
        $mercados = DB::connection('pgsql')->select('SELECT * FROM v_mercados WHERE ofna = :recaud', ['recaud' => $params['recaud']]);
        return [
            'status' => 'success',
            'message' => 'Mercados encontrados',
            'data' => $mercados
        ];
    }

    private function getSecciones()
    {
        $seccs = DB::connection('pgsql')->select('SELECT * FROM v_seccion');
        return [
            'status' => 'success',
            'message' => 'Secciones encontradas',
            'data' => $seccs
        ];
    }

    private function getFuncionarios()
    {
        $funcs = DB::connection('pgsql')->select('SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescmul WHERE cveautoriza <= 5');
        return [
            'status' => 'success',
            'message' => 'Funcionarios encontrados',
            'data' => $funcs
        ];
    }
}
