<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MantPagosContratosController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones del formulario MantPagosContratos
     * Entrada: eRequest con action, data
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $data = $request->input('data', []);
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'buscar_pago':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_buscar_pago(?, ?, ?, ?)', [
                        $data['fecha_pago'],
                        $data['oficina_pago'],
                        $data['caja_pago'],
                        $data['operacion_pago']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Pago encontrado'
                    ];
                    break;
                case 'agregar_pago':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_agregar_pago(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $data['colonia'],
                        $data['calle'],
                        $data['folio'],
                        $data['fecha_pago'],
                        $data['oficina_pago'],
                        $data['caja_pago'],
                        $data['operacion_pago'],
                        $data['pago_parcial'],
                        $data['total_parciales'],
                        $data['importe'],
                        $data['cve_descuento'],
                        $data['cve_bonificacion'],
                        $data['id_usuario']
                    ]);
                    $response = [
                        'status' => $result[0]->status,
                        'data' => $result,
                        'message' => $result[0]->message
                    ];
                    break;
                case 'modificar_pago':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_modificar_pago(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $data['colonia'],
                        $data['calle'],
                        $data['folio'],
                        $data['fecha_pago'],
                        $data['oficina_pago'],
                        $data['caja_pago'],
                        $data['operacion_pago'],
                        $data['pago_parcial'],
                        $data['total_parciales'],
                        $data['importe'],
                        $data['cve_descuento'],
                        $data['cve_bonificacion'],
                        $data['id_usuario']
                    ]);
                    $response = [
                        'status' => $result[0]->status,
                        'data' => $result,
                        'message' => $result[0]->message
                    ];
                    break;
                case 'borrar_pago':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_borrar_pago(?, ?, ?, ?)', [
                        $data['fecha_pago'],
                        $data['oficina_pago'],
                        $data['caja_pago'],
                        $data['operacion_pago']
                    ]);
                    $response = [
                        'status' => $result[0]->status,
                        'data' => $result,
                        'message' => $result[0]->message
                    ];
                    break;
                case 'buscar_contrato':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_buscar_contrato(?, ?, ?)', [
                        $data['colonia'],
                        $data['calle'],
                        $data['folio']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Contrato encontrado'
                    ];
                    break;
                case 'listar_recaudadoras':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_listar_recaudadoras()');
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Recaudadoras obtenidas'
                    ];
                    break;
                case 'listar_cajas':
                    $result = DB::select('SELECT * FROM sp_mantpagoscontratos_listar_cajas(?)', [
                        $data['oficina_pago']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Cajas obtenidas'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json($response);
    }
}
