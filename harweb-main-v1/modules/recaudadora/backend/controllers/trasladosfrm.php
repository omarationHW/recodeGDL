<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class TrasladosController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'buscar_pago':
                    $result = DB::select('SELECT * FROM buscar_pago(:recaud, :folio, :caja, :fecha, :importe)', [
                        'recaud' => $params['recaud'],
                        'folio' => $params['folio'],
                        'caja' => $params['caja'],
                        'fecha' => $params['fecha'],
                        'importe' => $params['importe']
                    ]);
                    if (empty($result)) {
                        $response['message'] = 'Pago no encontrado';
                    } else {
                        $response['success'] = true;
                        $response['data'] = $result;
                    }
                    break;
                case 'obtener_requerimientos':
                    $result = DB::select('SELECT * FROM obtener_requerimientos(:pago_id)', [
                        'pago_id' => $params['pago_id']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'aplicar_traslado':
                    $result = DB::select('SELECT * FROM aplicar_traslado(:pago_id, :tipo_aplicacion, :usuario)', [
                        'pago_id' => $params['pago_id'],
                        'tipo_aplicacion' => $params['tipo_aplicacion'],
                        'usuario' => $params['usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'liquidar_pago':
                    $result = DB::select('SELECT * FROM liquidar_pago(:pago_id, :usuario)', [
                        'pago_id' => $params['pago_id'],
                        'usuario' => $params['usuario']
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}
