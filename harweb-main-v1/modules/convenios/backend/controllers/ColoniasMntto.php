<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ColoniasMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'colonias.list':
                    $response['data'] = DB::select('SELECT c.colonia, c.descripcion, c.id_rec, c.id_zona, c.col_obra94, c.id_usuario, c.fecha_actual, z.zona, u.usuario FROM ta_17_colonias c LEFT JOIN ta_12_zonas z ON c.id_zona = z.id_zona LEFT JOIN ta_12_passwords u ON c.id_usuario = u.id_usuario ORDER BY c.colonia');
                    $response['success'] = true;
                    break;
                case 'colonias.create':
                    $validator = Validator::make($payload, [
                        'colonia' => 'required|integer',
                        'descripcion' => 'required|string|max:50',
                        'id_rec' => 'required|integer',
                        'id_zona' => 'required|integer',
                        'col_obra94' => 'nullable|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_colonias_create(?, ?, ?, ?, ?, ?)', [
                        $payload['colonia'],
                        $payload['descripcion'],
                        $payload['id_rec'],
                        $payload['id_zona'],
                        $payload['col_obra94'] ?? null,
                        $userId
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'colonias.update':
                    $validator = Validator::make($payload, [
                        'colonia' => 'required|integer',
                        'descripcion' => 'required|string|max:50',
                        'id_rec' => 'required|integer',
                        'id_zona' => 'required|integer',
                        'col_obra94' => 'nullable|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_colonias_update(?, ?, ?, ?, ?, ?)', [
                        $payload['colonia'],
                        $payload['descripcion'],
                        $payload['id_rec'],
                        $payload['id_zona'],
                        $payload['col_obra94'] ?? null,
                        $userId
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'colonias.delete':
                    $validator = Validator::make($payload, [
                        'colonia' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_colonias_delete(?)', [
                        $payload['colonia']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'colonias.get':
                    $validator = Validator::make($payload, [
                        'colonia' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $data = DB::select('SELECT * FROM ta_17_colonias WHERE colonia = ?', [$payload['colonia']]);
                    $response['success'] = true;
                    $response['data'] = $data ? $data[0] : null;
                    break;
                case 'colonias.catalogs':
                    $recs = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec');
                    $zonas = DB::select('SELECT id_zona, zona FROM ta_12_zonas ORDER BY id_zona');
                    $response['success'] = true;
                    $response['data'] = [
                        'recaudadoras' => $recs,
                        'zonas' => $zonas
                    ];
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }
}
