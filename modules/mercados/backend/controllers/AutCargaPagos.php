<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AutCargaPagosController extends Controller
{
    // Endpoint único para eRequest/eResponse
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
                case 'list':
                    $response['data'] = $this->list($params);
                    $response['success'] = true;
                    break;
                case 'create':
                    $response['data'] = $this->create($params, $userId);
                    $response['success'] = true;
                    break;
                case 'update':
                    $response['data'] = $this->update($params, $userId);
                    $response['success'] = true;
                    break;
                case 'show':
                    $response['data'] = $this->show($params);
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

    // Listar autorizaciones de carga de pagos
    private function list($params)
    {
        $oficina = $params['oficina'] ?? null;
        $query = "SELECT a.*, b.nombre, c.usuario
                  FROM ta_11_autcargapag a
                  JOIN ta_12_passwords b ON b.id_usuario = a.id_usupermiso
                  JOIN ta_12_passwords c ON c.id_usuario = a.id_usuario
                  WHERE a.oficina >= 1
                  ORDER BY a.fecha_ingreso DESC";
        if ($oficina) {
            $query = str_replace('a.oficina >= 1', 'a.oficina = ?', $query);
            return DB::select($query, [$oficina]);
        }
        return DB::select($query);
    }

    // Crear nueva autorización
    private function create($params, $userId)
    {
        $validator = Validator::make($params, [
            'fecha_ingreso' => 'required|date',
            'oficina' => 'required|integer',
            'autorizar' => 'required|string|in:S,N',
            'fecha_limite' => 'required|date',
            'id_usupermiso' => 'required|integer',
            'comentarios' => 'nullable|string'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_autcargapag_create(?,?,?,?,?,?,?)', [
            $params['fecha_ingreso'],
            $params['oficina'],
            $params['autorizar'],
            $params['fecha_limite'],
            $params['id_usupermiso'],
            $params['comentarios'] ?? '',
            $userId
        ]);
        return $result[0] ?? null;
    }

    // Actualizar autorización existente
    private function update($params, $userId)
    {
        $validator = Validator::make($params, [
            'fecha_ingreso' => 'required|date',
            'oficina' => 'required|integer',
            'autorizar' => 'required|string|in:S,N',
            'fecha_limite' => 'required|date',
            'id_usupermiso' => 'required|integer',
            'comentarios' => 'nullable|string'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_autcargapag_update(?,?,?,?,?,?,?)', [
            $params['fecha_ingreso'],
            $params['oficina'],
            $params['autorizar'],
            $params['fecha_limite'],
            $params['id_usupermiso'],
            $params['comentarios'] ?? '',
            $userId
        ]);
        return $result[0] ?? null;
    }

    // Mostrar detalle de una autorización
    private function show($params)
    {
        $validator = Validator::make($params, [
            'fecha_ingreso' => 'required|date',
            'oficina' => 'required|integer'
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_autcargapag_show(?,?)', [
            $params['fecha_ingreso'],
            $params['oficina']
        ]);
        return $result[0] ?? null;
    }
}
