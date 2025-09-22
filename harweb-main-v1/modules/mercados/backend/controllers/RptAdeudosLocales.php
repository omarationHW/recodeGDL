<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AdeudosLocalesController extends Controller
{
    /**
     * Endpoint único para manejar todas las operaciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'getRecaudadoras':
                    $data = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getAdeudosLocales':
                    $validator = Validator::make($eRequest['params'], [
                        'axo' => 'required|integer',
                        'oficina' => 'required|integer',
                        'periodo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL sp_get_adeudos_locales(?, ?, ?)', [
                        $eRequest['params']['axo'],
                        $eRequest['params']['oficina'],
                        $eRequest['params']['periodo']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'exportAdeudosLocalesExcel':
                    // Implementar lógica de exportación aquí (puede ser un job o return de URL temporal)
                    $eResponse['success'] = true;
                    $eResponse['message'] = 'Exportación en proceso';
                    break;
                case 'getMesesAdeudo':
                    $validator = Validator::make($eRequest['params'], [
                        'id_local' => 'required|integer',
                        'axo' => 'required|integer',
                        'periodo' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL sp_get_meses_adeudo(?, ?, ?)', [
                        $eRequest['params']['id_local'],
                        $eRequest['params']['axo'],
                        $eRequest['params']['periodo']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                case 'getRentaLocal':
                    $validator = Validator::make($eRequest['params'], [
                        'axo' => 'required|integer',
                        'categoria' => 'required|integer',
                        'seccion' => 'required|string',
                        'clave_cuota' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('CALL sp_get_renta_local(?, ?, ?, ?)', [
                        $eRequest['params']['axo'],
                        $eRequest['params']['categoria'],
                        $eRequest['params']['seccion'],
                        $eRequest['params']['clave_cuota']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $data;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }
        return response()->json(['eResponse' => $eResponse]);
    }
}
