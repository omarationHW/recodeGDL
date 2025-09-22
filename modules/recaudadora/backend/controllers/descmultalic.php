<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DescmultalicController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre descmultalic
     * Entrada: {
     *   "eRequest": {
     *     "action": "list|show|create|update|delete|cancel|folio|licencia|autoriza",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $result = null;
        $error = null;

        try {
            switch ($action) {
                case 'list':
                    $result = DB::select('SELECT * FROM descmultalic WHERE id_licencia = ?', [$params['id_licencia']]);
                    break;
                case 'show':
                    $result = DB::select('SELECT * FROM descmultalic WHERE id_descto = ?', [$params['id_descto']]);
                    break;
                case 'create':
                    $result = DB::select('SELECT * FROM sp_descmultalic_create(?, ?, ?, ?)', [
                        $params['id_licencia'],
                        $params['porcentaje'],
                        $params['autoriza'],
                        $params['useralta']
                    ]);
                    break;
                case 'update':
                    $result = DB::select('SELECT * FROM sp_descmultalic_update(?, ?, ?, ?, ?)', [
                        $params['id_descto'],
                        $params['porcentaje'],
                        $params['autoriza'],
                        $params['useract'],
                        $params['vigencia']
                    ]);
                    break;
                case 'delete':
                    $result = DB::select('SELECT * FROM sp_descmultalic_delete(?)', [$params['id_descto']]);
                    break;
                case 'cancel':
                    $result = DB::select('SELECT * FROM sp_descmultalic_cancel(?, ?)', [
                        $params['id_descto'],
                        $params['userbaja']
                    ]);
                    break;
                case 'folio':
                    $result = DB::select('SELECT * FROM sp_descmultalic_folio(?)', [$params['id_licencia']]);
                    break;
                case 'licencia':
                    $result = DB::select('SELECT * FROM licencias WHERE id_licencia = ?', [$params['id_licencia']]);
                    break;
                case 'autoriza':
                    $result = DB::select('SELECT * FROM c_autdescmul WHERE vigencia = ?', ['V']);
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
