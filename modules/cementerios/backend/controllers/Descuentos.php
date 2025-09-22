<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescuentosController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones de Descuentos
     * Entrada: {
     *   "eRequest": {
     *      "action": "listar|consultar|alta|modifica|baja|reactivar|tipos|adeudos|registro",
     *      ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest', []);
        $action = $input['action'] ?? '';
        $response = [];
        try {
            switch ($action) {
                case 'listar':
                    $response = $this->listar($input);
                    break;
                case 'consultar':
                    $response = $this->consultar($input);
                    break;
                case 'alta':
                    $response = $this->alta($input);
                    break;
                case 'modifica':
                    $response = $this->modifica($input);
                    break;
                case 'baja':
                    $response = $this->baja($input);
                    break;
                case 'reactivar':
                    $response = $this->reactivar($input);
                    break;
                case 'tipos':
                    $response = $this->tipos($input);
                    break;
                case 'adeudos':
                    $response = $this->adeudos($input);
                    break;
                case 'registro':
                    $response = $this->registro($input);
                    break;
                default:
                    return response()->json(['eResponse' => [
                        'ok' => false,
                        'message' => 'Acción no soportada',
                        'data' => null
                    ]]);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => [
                'ok' => false,
                'message' => $e->getMessage(),
                'data' => null
            ]]);
        }
    }

    private function listar($input)
    {
        // Listar descuentos activos
        $result = DB::select('SELECT * FROM ta_13_descpens WHERE vigencia = ? ORDER BY fecha_alta DESC', ['V']);
        return [
            'ok' => true,
            'message' => 'Listado de descuentos',
            'data' => $result
        ];
    }

    private function consultar($input)
    {
        // Consultar datos de una fosa por control_rcm
        $control = $input['control_rcm'] ?? null;
        if (!$control) {
            throw new \Exception('Falta parámetro control_rcm');
        }
        $fosa = DB::selectOne('SELECT * FROM ta_13_datosrcm WHERE control_rcm = ?', [$control]);
        return [
            'ok' => true,
            'message' => 'Datos de fosa',
            'data' => $fosa
        ];
    }

    private function alta($input)
    {
        // Alta de descuento usando SP
        $params = [
            $input['control_rcm'],
            $input['axo'],
            $input['porcentaje'],
            $input['usuario'],
            $input['reactivar'] ?? 'N',
            $input['tipo_descto'],
            1 // OPC 1 = alta
        ];
        $result = DB::select('SELECT * FROM spd_13_abcdesctos(?, ?, ?, ?, ?, ?, ?)', $params);
        $ok = $result[0]->par_ok == 0;
        return [
            'ok' => $ok,
            'message' => $result[0]->par_observ,
            'data' => null
        ];
    }

    private function modifica($input)
    {
        // Modificación de descuento usando SP
        $params = [
            $input['control_rcm'],
            $input['axo'],
            $input['porcentaje'],
            $input['usuario'],
            $input['reactivar'] ?? 'N',
            $input['tipo_descto'],
            3 // OPC 3 = modifica
        ];
        $result = DB::select('SELECT * FROM spd_13_abcdesctos(?, ?, ?, ?, ?, ?, ?)', $params);
        $ok = $result[0]->par_ok == 0;
        return [
            'ok' => $ok,
            'message' => $result[0]->par_observ,
            'data' => null
        ];
    }

    private function baja($input)
    {
        // Baja de descuento usando SP
        $params = [
            $input['control_rcm'],
            $input['axo'],
            $input['porcentaje'],
            $input['usuario'],
            $input['reactivar'] ?? 'N',
            $input['tipo_descto'],
            2 // OPC 2 = baja
        ];
        $result = DB::select('SELECT * FROM spd_13_abcdesctos(?, ?, ?, ?, ?, ?, ?)', $params);
        $ok = $result[0]->par_ok == 0;
        return [
            'ok' => $ok,
            'message' => $result[0]->par_observ,
            'data' => null
        ];
    }

    private function reactivar($input)
    {
        // Reactivar descuento usando SP
        $params = [
            $input['control_rcm'],
            $input['axo'],
            0, // porcentaje
            $input['usuario'],
            $input['reactivar'] ?? 'S',
            $input['tipo_descto'],
            4 // OPC 4 = reactivar
        ];
        $result = DB::select('SELECT * FROM spd_13_abcdesctos(?, ?, ?, ?, ?, ?, ?)', $params);
        $ok = $result[0]->par_ok == 0;
        return [
            'ok' => $ok,
            'message' => $result[0]->par_observ,
            'data' => null
        ];
    }

    private function tipos($input)
    {
        // Listar tipos de descuentos para un año
        $axo = $input['axo'] ?? date('Y');
        $result = DB::select('SELECT * FROM ta_13_descuentos WHERE tipo_descto <> ? AND axo_descto = ? ORDER BY axo_descto DESC, tipo_descto', ['N', $axo]);
        return [
            'ok' => true,
            'message' => 'Tipos de descuentos',
            'data' => $result
        ];
    }

    private function adeudos($input)
    {
        // Listar adeudos vigentes de una fosa
        $control = $input['control_rcm'] ?? null;
        if (!$control) {
            throw new \Exception('Falta parámetro control_rcm');
        }
        $result = DB::select('SELECT * FROM ta_13_adeudosrcm WHERE control_rcm = ? AND vigencia = ?', [$control, 'V']);
        return [
            'ok' => true,
            'message' => 'Adeudos vigentes',
            'data' => $result
        ];
    }

    private function registro($input)
    {
        // Listar descuentos registrados para una fosa
        $control = $input['control_rcm'] ?? null;
        if (!$control) {
            throw new \Exception('Falta parámetro control_rcm');
        }
        $result = DB::select('SELECT a.*, b.nombre, d.descrip_descto, c.nombre as nombre_mov FROM ta_13_descpens a LEFT JOIN ta_12_passwords b ON a.usuario = b.id_usuario LEFT JOIN ta_13_descuentos d ON d.axo_descto = a.axo_descto AND d.tipo_descto = a.tipo_descto LEFT JOIN ta_12_passwords c ON a.usuario_mov = c.id_usuario WHERE a.control_rcm = ?', [$control]);
        return [
            'ok' => true,
            'message' => 'Descuentos registrados',
            'data' => $result
        ];
    }
}
