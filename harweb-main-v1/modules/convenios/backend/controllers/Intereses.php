<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class InteresesController extends Controller
{
    // Endpoint único para eRequest/eResponse
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $data = $eRequest['data'] ?? [];
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($operation) {
                case 'list':
                    $result = DB::select('SELECT * FROM sp_intereses_list()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'create':
                    $validator = Validator::make($data, [
                        'axo' => 'required|integer',
                        'mes' => 'required|integer',
                        'porcentaje' => 'required|numeric|min:0.01',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_intereses_create(?, ?, ?, ?)', [
                        $data['axo'], $data['mes'], $data['porcentaje'], $data['id_usuario']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'update':
                    $validator = Validator::make($data, [
                        'axo' => 'required|integer',
                        'mes' => 'required|integer',
                        'porcentaje' => 'required|numeric|min:0.01',
                        'id_usuario' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_intereses_update(?, ?, ?, ?)', [
                        $data['axo'], $data['mes'], $data['porcentaje'], $data['id_usuario']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                case 'delete':
                    $validator = Validator::make($data, [
                        'axo' => 'required|integer',
                        'mes' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $eResponse['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_intereses_delete(?, ?)', [
                        $data['axo'], $data['mes']
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result[0] ?? null;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
