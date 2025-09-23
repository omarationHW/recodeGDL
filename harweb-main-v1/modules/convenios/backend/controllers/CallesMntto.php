<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CallesMnttoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $userId = $request->user() ? $request->user()->id : null;
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getCatalogs':
                    $response['data'] = [
                        'colonias' => DB::select('SELECT * FROM sp_get_colonias()'),
                        'tipos' => DB::select('SELECT * FROM sp_get_tipos()'),
                        'servicios' => DB::select('SELECT * FROM sp_get_servicios()'),
                        'cuentas' => DB::select('SELECT * FROM sp_get_cuentas()')
                    ];
                    $response['success'] = true;
                    break;
                case 'getCalle':
                    $colonia = $params['colonia'] ?? null;
                    $calle = $params['calle'] ?? null;
                    $result = DB::select('SELECT * FROM sp_get_calle(?, ?)', [$colonia, $calle]);
                    $response['data'] = $result;
                    $response['success'] = true;
                    break;
                case 'insertCalle':
                    $validator = Validator::make($params, [
                        'colonia' => 'required|integer',
                        'calle' => 'required|integer',
                        'tipo' => 'required|integer',
                        'servicio' => 'required|integer',
                        'desc_calle' => 'required|string',
                        'axo_obra' => 'required|integer',
                        'cuenta_ingreso' => 'required|integer',
                        'vigencia_obra' => 'required|string',
                        'plazo' => 'required|integer',
                        'clave_plazo' => 'required|string',
                        'cuenta_rezago' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_insert_calle(?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['colonia'],
                        $params['calle'],
                        $params['tipo'],
                        $params['servicio'],
                        $params['desc_calle'],
                        $params['axo_obra'],
                        $params['cuenta_ingreso'],
                        $params['vigencia_obra'],
                        $userId,
                        $params['plazo'],
                        $params['clave_plazo'],
                        $params['cuenta_rezago']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
                    break;
                case 'updateCalle':
                    $validator = Validator::make($params, [
                        'colonia' => 'required|integer',
                        'calle' => 'required|integer',
                        'tipo' => 'required|integer',
                        'servicio' => 'required|integer',
                        'desc_calle' => 'required|string',
                        'axo_obra' => 'required|integer',
                        'cuenta_ingreso' => 'required|integer',
                        'vigencia_obra' => 'required|string',
                        'plazo' => 'required|integer',
                        'clave_plazo' => 'required|string',
                        'cuenta_rezago' => 'required|integer'
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $result = DB::select('SELECT * FROM sp_update_calle(?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $params['colonia'],
                        $params['calle'],
                        $params['tipo'],
                        $params['servicio'],
                        $params['desc_calle'],
                        $params['axo_obra'],
                        $params['cuenta_ingreso'],
                        $params['vigencia_obra'],
                        $userId,
                        $params['plazo'],
                        $params['clave_plazo'],
                        $params['cuenta_rezago']
                    ]);
                    $response['success'] = $result[0]->success;
                    $response['message'] = $result[0]->message;
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
