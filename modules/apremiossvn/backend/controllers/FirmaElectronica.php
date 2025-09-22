<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class FirmaElectronicaController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones relacionadas con Firma Electrónica
     * Entrada: {
     *   "eRequest": {
     *     "action": "listarFolios|generarFirma|insertarFirma|listarFirmasGeneradas",
     *     ... parámetros ...
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'listarFolios':
                    $response = $this->listarFolios($input);
                    break;
                case 'generarFirma':
                    $response = $this->generarFirma($input);
                    break;
                case 'insertarFirma':
                    $response = $this->insertarFirma($input);
                    break;
                case 'listarFirmasGeneradas':
                    $response = $this->listarFirmasGeneradas($input);
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];
            }
        } catch (\Exception $e) {
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }

        return response()->json(["eResponse" => $response]);
    }

    /**
     * Listar folios a firmar según módulo y fecha
     */
    private function listarFolios($input)
    {
        $validator = Validator::make($input, [
            'modulo' => 'required|integer',
            'fecha' => 'required|date',
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $folios = DB::select('SELECT * FROM sp_firmaelectronica_listar_folios(?, ?)', [
            $input['modulo'], $input['fecha']
        ]);
        return ["success" => true, "message" => "Folios listados", "data" => $folios];
    }

    /**
     * Generar firma electrónica para un folio
     */
    private function generarFirma($input)
    {
        $validator = Validator::make($input, [
            'modulo' => 'required|integer',
            'tipoformato' => 'required|integer',
            'id' => 'required|integer',
            'fecha' => 'required|date',
            'cadenaoriginal' => 'required|string',
            'ruta' => 'nullable|string',
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $result = DB::select('SELECT * FROM sp_firmaelectronica_generar_firma(?,?,?,?,?,?)', [
            $input['modulo'],
            $input['tipoformato'],
            $input['id'],
            $input['fecha'],
            $input['cadenaoriginal'],
            $input['ruta'] ?? ''
        ]);
        return ["success" => true, "message" => "Firma generada", "data" => $result];
    }

    /**
     * Insertar firma electrónica en el sistema
     */
    private function insertarFirma($input)
    {
        $validator = Validator::make($input, [
            'secuencia' => 'required|integer',
            'digverificador' => 'required|string',
            'id_modulo' => 'required|integer',
            'fecha_graba' => 'required|date',
            'vigencia' => 'required|string',
            'firmante' => 'required|string',
            'cargo' => 'required|string',
            'validez' => 'required|string',
            'fecha_firmado' => 'required|string',
            'hash' => 'required|string',
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $result = DB::select('SELECT * FROM sp_firmaelectronica_insertar_firma(?,?,?,?,?,?,?,?,?,?)', [
            $input['secuencia'],
            $input['digverificador'],
            $input['id_modulo'],
            $input['fecha_graba'],
            $input['vigencia'],
            $input['firmante'],
            $input['cargo'],
            $input['validez'],
            $input['fecha_firmado'],
            $input['hash']
        ]);
        return ["success" => true, "message" => "Firma insertada", "data" => $result];
    }

    /**
     * Listar firmas generadas por módulo y fecha
     */
    private function listarFirmasGeneradas($input)
    {
        $validator = Validator::make($input, [
            'modulo' => 'required|integer',
            'fecha' => 'required|date',
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $firmas = DB::select('SELECT * FROM sp_firmaelectronica_listar_firmas_generadas(?, ?)', [
            $input['modulo'], $input['fecha']
        ]);
        return ["success" => true, "message" => "Firmas generadas listadas", "data" => $firmas];
    }
}
