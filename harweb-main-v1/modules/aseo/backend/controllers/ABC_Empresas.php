<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EmpresasController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'list':
                    $response['data'] = DB::select('SELECT * FROM ta_16_empresas ORDER BY descripcion, num_empresa, ctrol_emp');
                    $response['success'] = true;
                    break;
                case 'get':
                    $id = $payload['num_empresa'] ?? null;
                    $ctrol_emp = $payload['ctrol_emp'] ?? null;
                    $empresa = DB::selectOne('SELECT * FROM ta_16_empresas WHERE num_empresa = ? AND ctrol_emp = ?', [$id, $ctrol_emp]);
                    $response['data'] = $empresa;
                    $response['success'] = $empresa !== null;
                    break;
                case 'create':
                    $validator = Validator::make($payload, [
                        'ctrol_emp' => 'required|integer',
                        'descripcion' => 'required|string',
                        'representante' => 'required|string',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    // Obtener el siguiente num_empresa
                    $max = DB::table('ta_16_empresas')->where('ctrol_emp', $payload['ctrol_emp'])->max('num_empresa');
                    $num_empresa = $max ? $max + 1 : 1;
                    DB::insert('INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante) VALUES (?, ?, ?, ?)', [
                        $num_empresa,
                        $payload['ctrol_emp'],
                        $payload['descripcion'],
                        $payload['representante']
                    ]);
                    $response['success'] = true;
                    $response['data'] = [
                        'num_empresa' => $num_empresa,
                        'ctrol_emp' => $payload['ctrol_emp']
                    ];
                    break;
                case 'update':
                    $validator = Validator::make($payload, [
                        'num_empresa' => 'required|integer',
                        'ctrol_emp' => 'required|integer',
                        'descripcion' => 'required|string',
                        'representante' => 'required|string',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    $affected = DB::update('UPDATE ta_16_empresas SET descripcion = ?, representante = ? WHERE num_empresa = ? AND ctrol_emp = ?', [
                        $payload['descripcion'],
                        $payload['representante'],
                        $payload['num_empresa'],
                        $payload['ctrol_emp']
                    ]);
                    $response['success'] = $affected > 0;
                    break;
                case 'delete':
                    $validator = Validator::make($payload, [
                        'num_empresa' => 'required|integer',
                        'ctrol_emp' => 'required|integer',
                    ]);
                    if ($validator->fails()) {
                        $response['message'] = $validator->errors()->first();
                        break;
                    }
                    // Verificar si existen contratos asociados
                    $contratos = DB::table('ta_16_contratos')
                        ->where('num_empresa', $payload['num_empresa'])
                        ->where('ctrol_emp', $payload['ctrol_emp'])
                        ->count();
                    if ($contratos > 0) {
                        $response['message'] = 'No se puede eliminar la empresa porque tiene contratos asociados.';
                        break;
                    }
                    $deleted = DB::delete('DELETE FROM ta_16_empresas WHERE num_empresa = ? AND ctrol_emp = ?', [
                        $payload['num_empresa'],
                        $payload['ctrol_emp']
                    ]);
                    $response['success'] = $deleted > 0;
                    break;
                case 'search':
                    $query = DB::table('ta_16_empresas as a')
                        ->join('ta_16_tipos_emp as b', 'a.ctrol_emp', '=', 'b.ctrol_emp')
                        ->select('a.num_empresa', 'a.ctrol_emp', 'b.tipo_empresa', 'a.descripcion', 'a.representante');
                    if (!empty($payload['descripcion'])) {
                        $query->where('a.descripcion', 'ilike', '%' . $payload['descripcion'] . '%');
                    }
                    if (!empty($payload['ctrol_emp'])) {
                        $query->where('a.ctrol_emp', $payload['ctrol_emp']);
                    }
                    $response['data'] = $query->orderBy('a.descripcion')->orderBy('a.num_empresa')->orderBy('b.ctrol_emp')->get();
                    $response['success'] = true;
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
