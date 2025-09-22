<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FrmEjeController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario FrmEje
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['eRequest']['action'] ?? null;
        $params = $input['eRequest']['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no válida'
        ];

        try {
            switch ($action) {
                case 'listEjecutores':
                    $data = DB::select('SELECT * FROM ejecutores WHERE vigente = true ORDER BY cveejecutor');
                    $response = ['status' => 'ok', 'data' => $data, 'message' => ''];
                    break;
                case 'getEjecutor':
                    $id = $params['cveejecutor'] ?? null;
                    $data = DB::selectOne('SELECT * FROM ejecutores WHERE cveejecutor = ?', [$id]);
                    $response = ['status' => $data ? 'ok' : 'not_found', 'data' => $data, 'message' => $data ? '' : 'No encontrado'];
                    break;
                case 'createEjecutor':
                    $validator = Validator::make($params, [
                        'paterno' => 'required',
                        'materno' => 'required',
                        'nombres' => 'required',
                        'rfc' => 'required',
                        'recaud' => 'required|integer',
                        'oficio' => 'required',
                        'fecing' => 'required|date',
                        'fecinic' => 'required|date',
                        'fecterm' => 'required|date',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_eje_create(?,?,?,?,?,?,?,?,?,?)', [
                        $params['paterno'], $params['materno'], $params['nombres'], $params['rfc'], $params['recaud'], $params['oficio'], $params['fecing'], $params['fecinic'], $params['fecterm'], auth()->user()->name
                    ]);
                    $response = ['status' => 'ok', 'data' => $result, 'message' => 'Ejecutor creado'];
                    break;
                case 'updateEjecutor':
                    $id = $params['cveejecutor'] ?? null;
                    $result = DB::select('SELECT * FROM sp_eje_update(?,?,?,?,?,?,?,?,?,?,?)', [
                        $id, $params['paterno'], $params['materno'], $params['nombres'], $params['rfc'], $params['recaud'], $params['oficio'], $params['fecing'], $params['fecinic'], $params['fecterm'], auth()->user()->name
                    ]);
                    $response = ['status' => 'ok', 'data' => $result, 'message' => 'Ejecutor actualizado'];
                    break;
                case 'deleteEjecutor':
                    $id = $params['cveejecutor'] ?? null;
                    $result = DB::select('SELECT * FROM sp_eje_delete(?)', [$id]);
                    $response = ['status' => 'ok', 'data' => $result, 'message' => 'Ejecutor eliminado'];
                    break;
                case 'reportEjecutores':
                    $data = DB::select('SELECT * FROM sp_eje_report(?, ?, ?)', [
                        $params['fecha_inicio'] ?? null,
                        $params['fecha_fin'] ?? null,
                        $params['recaud'] ?? null
                    ]);
                    $response = ['status' => 'ok', 'data' => $data, 'message' => 'Reporte generado'];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['status'] = 'error';
            $response['message'] = $e->getMessage();
        }
        return response()->json(['eResponse' => $response]);
    }
}
