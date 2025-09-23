<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'tipos_aseo.list':
                    $result = DB::select('SELECT * FROM ta_16_tipo_aseo ORDER BY ctrol_aseo');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'tipos_aseo.create':
                    $sp = DB::select('SELECT * FROM sp_tipos_aseo_create(?, ?, ?, ?)', [
                        $params['tipo_aseo'],
                        $params['descripcion'],
                        $params['cta_aplicacion'],
                        $params['usuario']
                    ]);
                    $eResponse['success'] = $sp[0]->success;
                    $eResponse['message'] = $sp[0]->msg;
                    break;
                case 'tipos_aseo.update':
                    $sp = DB::select('SELECT * FROM sp_tipos_aseo_update(?, ?, ?, ?, ?)', [
                        $params['ctrol_aseo'],
                        $params['tipo_aseo'],
                        $params['descripcion'],
                        $params['cta_aplicacion'],
                        $params['usuario']
                    ]);
                    $eResponse['success'] = $sp[0]->success;
                    $eResponse['message'] = $sp[0]->msg;
                    break;
                case 'tipos_aseo.delete':
                    $sp = DB::select('SELECT * FROM sp_tipos_aseo_delete(?, ?)', [
                        $params['ctrol_aseo'],
                        $params['usuario']
                    ]);
                    $eResponse['success'] = $sp[0]->success;
                    $eResponse['message'] = $sp[0]->msg;
                    break;
                case 'tipos_aseo.get':
                    $result = DB::select('SELECT * FROM ta_16_tipo_aseo WHERE ctrol_aseo = ?', [$params['ctrol_aseo']]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
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
