<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PropuestatabController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre Propuestatab
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|show|create|update|delete|history|regimen|values|diferencias|obs400|cfs400|escrituras|condominio",
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
                case 'list':
                    $result = DB::select('SELECT * FROM propuestatab_list(:cvecuenta)', $params);
                    break;
                case 'show':
                    $result = DB::select('SELECT * FROM propuestatab_show(:id)', $params);
                    break;
                case 'create':
                    $result = DB::select('SELECT * FROM propuestatab_create(:data)', [json_encode($params['data'])]);
                    break;
                case 'update':
                    $result = DB::select('SELECT * FROM propuestatab_update(:id, :data)', [
                        'id' => $params['id'],
                        'data' => json_encode($params['data'])
                    ]);
                    break;
                case 'delete':
                    $result = DB::select('SELECT * FROM propuestatab_delete(:id)', $params);
                    break;
                case 'history':
                    $result = DB::select('SELECT * FROM propuestatab_history(:cvecuenta)', $params);
                    break;
                case 'regimen':
                    $result = DB::select('SELECT * FROM propuestatab_regimen(:cvecuenta)', $params);
                    break;
                case 'values':
                    $result = DB::select('SELECT * FROM propuestatab_values(:cvecuenta)', $params);
                    break;
                case 'diferencias':
                    $result = DB::select('SELECT * FROM propuestatab_diferencias(:cvecuenta)', $params);
                    break;
                case 'obs400':
                    $result = DB::select('SELECT * FROM propuestatab_obs400(:recaud, :urbrus, :cuenta)', $params);
                    break;
                case 'cfs400':
                    $result = DB::select('SELECT * FROM propuestatab_cfs400(:recaud, :urbrus, :cuenta)', $params);
                    break;
                case 'escrituras':
                    $result = DB::select('SELECT * FROM propuestatab_escrituras(:recaud, :cuenta)', $params);
                    break;
                case 'condominio':
                    $result = DB::select('SELECT * FROM propuestatab_condominio(:cvecatnva)', $params);
                    break;
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
