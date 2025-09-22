<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class TitulosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones sobre Titulos
     * Entrada: {
     *   "eRequest": {
     *     "action": "search|update|print|view|validate|extra",
     *     "data": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? '';
        $data = $input['data'] ?? [];
        $response = [];
        try {
            switch ($action) {
                case 'search':
                    $response = $this->searchTitulo($data);
                    break;
                case 'update':
                    $response = $this->updateTitulo($data);
                    break;
                case 'print':
                    $response = $this->printTitulo($data);
                    break;
                case 'view':
                    $response = $this->viewTitulo($data);
                    break;
                case 'validate':
                    $response = $this->validateTitulo($data);
                    break;
                case 'extra':
                    $response = $this->extraTitulo($data);
                    break;
                default:
                    return response()->json(['eResponse' => ['error' => 'Acción no soportada']], 400);
            }
            return response()->json(['eResponse' => $response]);
        } catch (\Exception $e) {
            return response()->json(['eResponse' => ['error' => $e->getMessage()]], 500);
        }
    }

    /**
     * Buscar Titulo por fecha, folio y operación
     */
    private function searchTitulo($data)
    {
        $validator = Validator::make($data, [
            'fecha' => 'required|date',
            'folio' => 'required|integer',
            'operacion' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_titulos_search(?, ?, ?)', [
            $data['fecha'], $data['folio'], $data['operacion']
        ]);
        return ['result' => $result];
    }

    /**
     * Actualizar datos de beneficiario de un Titulo
     */
    private function updateTitulo($data)
    {
        $validator = Validator::make($data, [
            'control_rcm' => 'required|integer',
            'titulo' => 'required|integer',
            'fecha' => 'required|date',
            'libro' => 'required|integer',
            'axo' => 'required|integer',
            'folio' => 'required|integer',
            'nombre' => 'required|string',
            'domicilio' => 'required|string',
            'colonia' => 'required|string',
            'telefono' => 'nullable|string',
            'partida' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_titulos_update(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $data['control_rcm'],
            $data['titulo'],
            $data['fecha'],
            $data['libro'],
            $data['axo'],
            $data['folio'],
            $data['nombre'],
            $data['domicilio'],
            $data['colonia'],
            $data['telefono'] ?? '',
            $data['partida'] ?? ''
        ]);
        return ['result' => $result];
    }

    /**
     * Imprimir Titulo (devuelve datos para impresión)
     */
    private function printTitulo($data)
    {
        $validator = Validator::make($data, [
            'fecha' => 'required|date',
            'folio' => 'required|integer',
            'operacion' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_titulos_print(?, ?, ?)', [
            $data['fecha'], $data['folio'], $data['operacion']
        ]);
        return ['result' => $result];
    }

    /**
     * Vista previa de datos de beneficiario
     */
    private function viewTitulo($data)
    {
        $validator = Validator::make($data, [
            'fecha' => 'required|date',
            'folio' => 'required|integer',
            'operacion' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_titulos_view(?, ?, ?)', [
            $data['fecha'], $data['folio'], $data['operacion']
        ]);
        return ['result' => $result];
    }

    /**
     * Validar existencia de Titulo
     */
    private function validateTitulo($data)
    {
        $validator = Validator::make($data, [
            'fecha' => 'required|date',
            'folio' => 'required|integer',
            'operacion' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_titulos_validate(?, ?, ?)', [
            $data['fecha'], $data['folio'], $data['operacion']
        ]);
        return ['result' => $result];
    }

    /**
     * Extra: obtener datos extendidos (vista)
     */
    private function extraTitulo($data)
    {
        $validator = Validator::make($data, [
            'fecha' => 'required|date',
            'folio' => 'required|integer',
            'operacion' => 'required|integer',
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM sp_titulos_extra(?, ?, ?)', [
            $data['fecha'], $data['folio'], $data['operacion']
        ]);
        return ['result' => $result];
    }
}
