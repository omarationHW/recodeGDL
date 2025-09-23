<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class AutorizaDesController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descuentos autorizados
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|alta|modificar|baja|catalogo_quien|catalogo_aplicacion|catalogo_oficina",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $result = null;
        $error = null;
        try {
            switch ($action) {
                case 'search':
                    $result = DB::select('SELECT * FROM sp_autorizades_search(?, ?, ?, ?)', [
                        $input['folio'] ?? null,
                        $input['id_rec'] ?? null,
                        $input['id_modulo'] ?? null,
                        $input['usuario_id'] ?? null
                    ]);
                    break;
                case 'alta':
                    $result = DB::select('SELECT * FROM sp_autorizades_alta(?, ?, ?, ?, ?, ?)', [
                        $input['id_control'],
                        $input['id_rec'],
                        $input['cveaut'],
                        $input['porcentaje'],
                        $input['fecha_alta'],
                        $input['usuario_id']
                    ]);
                    break;
                case 'modificar':
                    $result = DB::select('SELECT * FROM sp_autorizades_modificar(?, ?, ?, ?, ?, ?)', [
                        $input['id_control'],
                        $input['id_rec'],
                        $input['cveaut'],
                        $input['porcentaje'],
                        $input['fecha_alta'],
                        $input['usuario_id']
                    ]);
                    break;
                case 'baja':
                    $result = DB::select('SELECT * FROM sp_autorizades_baja(?, ?, ?, ?)', [
                        $input['id_control'],
                        $input['fecha_baja'],
                        $input['usuario_id'],
                        $input['motivo'] ?? null
                    ]);
                    break;
                case 'catalogo_quien':
                    $result = DB::select('SELECT * FROM sp_autorizades_catalogo_quien(?)', [
                        $input['usuario_id']
                    ]);
                    break;
                case 'catalogo_aplicacion':
                    $result = DB::select('SELECT * FROM sp_autorizades_catalogo_aplicacion()');
                    break;
                case 'catalogo_oficina':
                    $result = DB::select('SELECT * FROM sp_autorizades_catalogo_oficina()');
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }
        return response()->json([
            'eResponse' => [
                'result' => $result,
                'error' => $error
            ]
        ]);
    }
}
