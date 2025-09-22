<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class SolicNoOficialController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'eResponse' => [
                'success' => false,
                'message' => '',
                'data' => null
            ]
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['eResponse']['data'] = DB::select('SELECT * FROM solicnooficial ORDER BY axo DESC, folio DESC');
                    $response['eResponse']['success'] = true;
                    break;
                case 'search':
                    $type = $params['type'] ?? 'propietario';
                    $value = strtoupper($params['value'] ?? '');
                    $sql = 'SELECT * FROM solicnooficial';
                    if ($value) {
                        if ($type === 'propietario') {
                            $sql .= ' WHERE propietario ILIKE ?';
                        } else {
                            $sql .= ' WHERE ubicacion ILIKE ?';
                        }
                        $sql .= ' ORDER BY axo DESC, folio DESC';
                        $response['eResponse']['data'] = DB::select($sql, ['%' . $value . '%']);
                    } else {
                        $sql .= ' ORDER BY axo DESC, folio DESC';
                        $response['eResponse']['data'] = DB::select($sql);
                    }
                    $response['eResponse']['success'] = true;
                    break;
                case 'get':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $row = DB::selectOne('SELECT * FROM solicnooficial WHERE axo = ? AND folio = ?', [$axo, $folio]);
                    $response['eResponse']['data'] = $row;
                    $response['eResponse']['success'] = $row ? true : false;
                    break;
                case 'create':
                    $data = $params['data'] ?? [];
                    $validator = Validator::make($data, [
                        'propietario' => 'required|string|max:50',
                        'actividad' => 'required|string|max:80',
                        'ubicacion' => 'required|string|max:75',
                        'zona' => 'required|integer',
                        'subzona' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['eResponse']['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_solicnooficial_create(?,?,?,?,?,?,?)', [
                        $data['propietario'],
                        $data['actividad'],
                        $data['ubicacion'],
                        $data['zona'],
                        $data['subzona'],
                        auth()->user()->username ?? 'api',
                        date('Y-m-d')
                    ]);
                    $response['eResponse']['data'] = $result[0] ?? null;
                    $response['eResponse']['success'] = true;
                    break;
                case 'update':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $data = $params['data'] ?? [];
                    $result = DB::select('SELECT * FROM sp_solicnooficial_update(?,?,?,?,?,?,?)', [
                        $axo,
                        $folio,
                        $data['propietario'] ?? null,
                        $data['actividad'] ?? null,
                        $data['ubicacion'] ?? null,
                        $data['zona'] ?? null,
                        $data['subzona'] ?? null
                    ]);
                    $response['eResponse']['data'] = $result[0] ?? null;
                    $response['eResponse']['success'] = true;
                    break;
                case 'cancel':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_solicnooficial_cancel(?,?)', [$axo, $folio]);
                    $response['eResponse']['data'] = $result[0] ?? null;
                    $response['eResponse']['success'] = true;
                    break;
                case 'print':
                    $axo = $params['axo'] ?? null;
                    $folio = $params['folio'] ?? null;
                    $result = DB::select('SELECT * FROM sp_solicnooficial_print(?,?)', [$axo, $folio]);
                    $response['eResponse']['data'] = $result[0] ?? null;
                    $response['eResponse']['success'] = true;
                    break;
                default:
                    $response['eResponse']['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['eResponse']['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
