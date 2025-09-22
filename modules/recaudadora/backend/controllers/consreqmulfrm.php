<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MultasController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones sobre multas y requerimientos asociados
     * Entrada: eRequest con action, params
     * Salida: eResponse con status, data, message
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'status' => 'error',
            'data' => null,
            'message' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'getMultaById':
                    $validator = Validator::make($params, [
                        'id_multa' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM multas WHERE id_multa = ?', [$params['id_multa']]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Multa encontrada'
                    ];
                    break;
                case 'searchMultas':
                    $where = [];
                    $bindings = [];
                    if (!empty($params['contribuyente'])) {
                        $where[] = 'contribuyente ILIKE ?';
                        $bindings[] = '%' . $params['contribuyente'] . '%';
                    }
                    if (!empty($params['domicilio'])) {
                        $where[] = 'domicilio ILIKE ?';
                        $bindings[] = '%' . $params['domicilio'] . '%';
                    }
                    if (!empty($params['id_dependencia'])) {
                        $where[] = 'id_dependencia = ?';
                        $bindings[] = $params['id_dependencia'];
                    }
                    $sql = 'SELECT * FROM multas';
                    if (count($where)) {
                        $sql .= ' WHERE ' . implode(' AND ', $where);
                    }
                    $sql .= ' ORDER BY axo_acta, num_acta';
                    $data = DB::select($sql, $bindings);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Resultados de búsqueda'
                    ];
                    break;
                case 'getRequerimientosByMulta':
                    $validator = Validator::make($params, [
                        'id_multa' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM reqmultas WHERE id_multa = ? ORDER BY axoreq, folioreq', [$params['id_multa']]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Requerimientos asociados a la multa'
                    ];
                    break;
                case 'updateMulta':
                    $validator = Validator::make($params, [
                        'id_multa' => 'required|integer',
                        'calificacion' => 'required|numeric',
                        'multa' => 'required|numeric',
                        'comentario' => 'nullable|string',
                        'user' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::update('UPDATE multas SET calificacion = ?, multa = ?, comentario = ?, capturista = ?, updated_at = NOW() WHERE id_multa = ?', [
                        $params['calificacion'],
                        $params['multa'],
                        $params['comentario'] ?? '',
                        $params['user'],
                        $params['id_multa']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => null,
                        'message' => 'Multa actualizada correctamente'
                    ];
                    break;
                case 'cancelMulta':
                    $validator = Validator::make($params, [
                        'id_multa' => 'required|integer',
                        'user' => 'required|string',
                        'observacion' => 'required|string'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    DB::beginTransaction();
                    DB::update('UPDATE multas SET fecha_cancelacion = NOW(), user_baja = ?, comentario = ? WHERE id_multa = ?', [
                        $params['user'],
                        $params['observacion'],
                        $params['id_multa']
                    ]);
                    DB::update('UPDATE reqmultas SET vigencia = ? WHERE id_multa = ?', ['C', $params['id_multa']]);
                    DB::commit();
                    $response = [
                        'status' => 'success',
                        'data' => null,
                        'message' => 'Multa y requerimientos asociados cancelados'
                    ];
                    break;
                case 'getPrescripcion':
                    $validator = Validator::make($params, [
                        'id_prescri' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM presc_multas WHERE id_prescri = ?', [$params['id_prescri']]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Prescripción encontrada'
                    ];
                    break;
                case 'getMultasHistorico':
                    $validator = Validator::make($params, [
                        'id_dependencia' => 'required|integer',
                        'axo_acta' => 'required|integer',
                        'num_acta' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM h_multasnvo WHERE id_dependencia = ? AND axo_acta = ? AND num_acta = ?', [
                        $params['id_dependencia'],
                        $params['axo_acta'],
                        $params['num_acta']
                    ]);
                    $response = [
                        'status' => 'success',
                        'data' => $data,
                        'message' => 'Histórico de multas encontrado'
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response = [
                'status' => 'error',
                'data' => null,
                'message' => $e->getMessage()
            ];
        }
        return response()->json($response);
    }
}
