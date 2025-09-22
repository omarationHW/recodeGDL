<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class DictamenUsoDeSueloController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre dictamenusodesuelo
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|create|update|cancel|print|search|listado",
     *     "data": { ... }
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
        $data = $input['data'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_list()');
                    break;
                case 'search':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_search(?, ?, ?, ?, ?)', [
                        $data['axo'] ?? null,
                        $data['folio'] ?? null,
                        $data['licencia'] ?? null,
                        $data['fecha_ini'] ?? null,
                        $data['fecha_fin'] ?? null
                    ]);
                    break;
                case 'create':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_create(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $data['solicita'],
                        $data['partidapago'],
                        $data['observacion'],
                        $data['domicilio'],
                        $data['id_licencia'],
                        $data['capturista'],
                        $data['tipo'],
                        $data['recaud'],
                        $data['actividad'],
                        $data['propietario'],
                        $data['ubicacion'],
                        $data['numext_ubic'],
                        $data['letraext_ubic'],
                        $data['numint_ubic'],
                        $data['letraint_ubic'],
                        $data['sup_construida'],
                        $data['sup_autorizada'],
                        $data['num_cajones'],
                        $data['num_empleados'],
                        $data['vigente'],
                        $data['feccap']
                    ]);
                    break;
                case 'update':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_update(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        $data['axo'],
                        $data['folio'],
                        $data['solicita'],
                        $data['partidapago'],
                        $data['observacion'],
                        $data['domicilio'],
                        $data['id_licencia'],
                        $data['capturista'],
                        $data['tipo'],
                        $data['recaud'],
                        $data['actividad'],
                        $data['propietario'],
                        $data['ubicacion'],
                        $data['numext_ubic'],
                        $data['letraext_ubic'],
                        $data['numint_ubic'],
                        $data['letraint_ubic'],
                        $data['sup_construida'],
                        $data['sup_autorizada'],
                        $data['num_cajones'],
                        $data['num_empleados'],
                        $data['vigente']
                    ]);
                    break;
                case 'cancel':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_cancel(?, ?, ?)', [
                        $data['axo'],
                        $data['folio'],
                        $data['motivo']
                    ]);
                    break;
                case 'print':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_print(?, ?)', [
                        $data['axo'],
                        $data['folio']
                    ]);
                    break;
                case 'listado':
                    $result = DB::select('SELECT * FROM dictamenusodesuelo_listado(?, ?, ?, ?, ?)', [
                        $data['axo'] ?? null,
                        $data['folio'] ?? null,
                        $data['licencia'] ?? null,
                        $data['fecha_ini'] ?? null,
                        $data['fecha_fin'] ?? null
                    ]);
                    break;
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $error = $e->getMessage();
        }

        return response()->json([
            'eResponse' => [
                'success' => $error ? false : true,
                'data' => $result,
                'error' => $error
            ]
        ]);
    }
}
