<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario de carga.
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
     *     "params": { ... }
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
        $params = $input['params'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'getPredioByClaveCatastral':
                    $result = DB::select('SELECT * FROM get_predio_by_clave_catastral(?, ?)', [
                        $params['cvecatnva'] ?? '',
                        $params['subpredio'] ?? 0
                    ]);
                    break;
                case 'getPredioByCuenta':
                    $result = DB::select('SELECT * FROM get_predio_by_cuenta(?, ?, ?)', [
                        $params['recaud'] ?? 0,
                        $params['urbrus'] ?? '',
                        $params['cuenta'] ?? 0
                    ]);
                    break;
                case 'getCartografia':
                    $result = DB::select('SELECT * FROM get_cartografia_predial(?)', [
                        $params['cvecatnva'] ?? ''
                    ]);
                    break;
                case 'getNumerosOficiales':
                    $result = DB::select('SELECT * FROM get_numeros_oficiales(?)', [
                        $params['cvemanz'] ?? ''
                    ]);
                    break;
                case 'getCondominio':
                    $result = DB::select('SELECT * FROM get_condominio(?)', [
                        $params['cvecatnva'] ?? ''
                    ]);
                    break;
                case 'getAvaluo':
                    $result = DB::select('SELECT * FROM get_avaluo(?)', [
                        $params['cvecatnva'] ?? ''
                    ]);
                    break;
                case 'getConstrucciones':
                    $result = DB::select('SELECT * FROM get_construcciones(?)', [
                        $params['cvecatnva'] ?? ''
                    ]);
                    break;
                // ... otros casos según lógica del formulario
                default:
                    $error = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $error = $ex->getMessage();
        }

        return response()->json([
            'eResponse' => $error ? ['error' => $error] : $result
        ]);
    }
}
