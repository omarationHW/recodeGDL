<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ModifConvDiversosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Convenios Diversos
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Asume autenticación JWT
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'buscarConvenio':
                    $data = DB::select('SELECT * FROM sp_buscar_convenio_diversos(?, ?, ?, ?, ?, ?)', [
                        $params['tipo'],
                        $params['subtipo'],
                        $params['letras_ofi'] ?? null,
                        $params['folio_ofi'] ?? null,
                        $params['alo_oficio'] ?? null,
                        $params['manzana'] ?? null
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Convenio encontrado'
                    ];
                    break;
                case 'modificarDatosGenerales':
                    $result = DB::select('SELECT * FROM sp_modificar_datos_generales_convenio_diversos(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['id_conv_resto'],
                        $params['id_rec'],
                        $params['id_zona'],
                        $params['nombre'],
                        $params['calle'],
                        $params['num_exterior'],
                        $params['num_interior'],
                        $params['inciso'],
                        $params['metros'],
                        $params['observaciones'],
                        $user->id,
                        now(),
                        $params['telefono'],
                        $params['correo'],
                        $params['oficio'],
                        $params['fechaoficio'],
                        $params['nombrefirma'],
                        $params['tipo'],
                        $params['subtipo'],
                        $params['manzana'],
                        $params['lote'],
                        $params['letra'],
                        $params['letras_ofi'],
                        $params['folio_ofi'],
                        $params['alo_oficio'],
                        $params['modulo']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Datos generales modificados correctamente'
                    ];
                    break;
                case 'bloquearConvenio':
                    $result = DB::select('SELECT * FROM sp_bloquear_convenio_diversos(?,?,?,?)', [
                        $params['id_conv_resto'],
                        $user->id,
                        now(),
                        $params['observaciones']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Convenio bloqueado correctamente'
                    ];
                    break;
                case 'desbloquearConvenio':
                    $result = DB::select('SELECT * FROM sp_desbloquear_convenio_diversos(?,?,?,?)', [
                        $params['id_conv_resto'],
                        $user->id,
                        now(),
                        $params['observaciones']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Convenio desbloqueado correctamente'
                    ];
                    break;
                case 'darPagadoConvenio':
                    $result = DB::select('SELECT * FROM sp_dar_pagado_convenio_diversos(?,?,?,?)', [
                        $params['id_conv_resto'],
                        $user->id,
                        now(),
                        $params['modulo']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Convenio marcado como pagado'
                    ];
                    break;
                case 'darBajaConvenio':
                    $result = DB::select('SELECT * FROM sp_dar_baja_convenio_diversos(?,?,?,?)', [
                        $params['id_conv_resto'],
                        $user->id,
                        now(),
                        $params['modulo']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $result,
                        'message' => 'Convenio dado de baja'
                    ];
                    break;
                case 'listarTipos':
                    $data = DB::select('SELECT * FROM sp_listar_tipos_convenio_diversos()');
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Tipos listados'
                    ];
                    break;
                case 'listarSubtipos':
                    $data = DB::select('SELECT * FROM sp_listar_subtipos_convenio_diversos(?)', [
                        $params['tipo']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Subtipos listados'
                    ];
                    break;
                // ... otros casos según lógica Delphi ...
                default:
                    $response['message'] = 'Acción no implementada';
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
