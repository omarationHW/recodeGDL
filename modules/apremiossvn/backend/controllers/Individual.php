<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class IndividualController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getFolio':
                    $folio = $params['folio'] ?? null;
                    if (!$folio) {
                        throw new \Exception('Folio requerido');
                    }
                    $result = DB::select('SELECT * FROM get_individual_folio(:folio)', ['folio' => $folio]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getFolioHistory':
                    $id_control = $params['id_control'] ?? null;
                    if (!$id_control) {
                        throw new \Exception('id_control requerido');
                    }
                    $result = DB::select('SELECT * FROM get_individual_folio_history(:id_control)', ['id_control' => $id_control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getFolioPeriods':
                    $id_control = $params['id_control'] ?? null;
                    if (!$id_control) {
                        throw new \Exception('id_control requerido');
                    }
                    $result = DB::select('SELECT * FROM get_individual_folio_periods(:id_control)', ['id_control' => $id_control]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'getModuleDetails':
                    $modulo = $params['modulo'] ?? null;
                    $control_otr = $params['control_otr'] ?? null;
                    if (!$modulo || !$control_otr) {
                        throw new \Exception('modulo y control_otr requeridos');
                    }
                    $result = DB::select('SELECT * FROM get_module_details(:modulo, :control_otr)', [
                        'modulo' => $modulo,
                        'control_otr' => $control_otr
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
