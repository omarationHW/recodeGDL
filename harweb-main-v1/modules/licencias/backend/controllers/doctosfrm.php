<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DoctosFrmController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario doctosfrm
     * Entrada: {
     *   "eRequest": {
     *     "action": "get|save|clear|list|delete",
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
        $action = $input['action'] ?? null;
        $data = $input['data'] ?? [];
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        switch ($action) {
            case 'get':
                $response = $this->getDocumentos($data);
                break;
            case 'save':
                $response = $this->saveDocumentos($data);
                break;
            case 'clear':
                $response = $this->clearDocumentos($data);
                break;
            case 'list':
                $response = $this->listDocumentos($data);
                break;
            case 'delete':
                $response = $this->deleteDocumento($data);
                break;
            default:
                $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    /**
     * Obtener documentos seleccionados para un trámite
     */
    private function getDocumentos($data)
    {
        $tramite_id = $data['tramite_id'] ?? null;
        if (!$tramite_id) {
            return ["success" => false, "message" => "tramite_id requerido", "data" => null];
        }
        $docs = DB::select('SELECT * FROM sp_doctosfrm_get(:tramite_id)', ["tramite_id" => $tramite_id]);
        return ["success" => true, "message" => "Documentos obtenidos", "data" => $docs];
    }

    /**
     * Guardar documentos seleccionados para un trámite
     */
    private function saveDocumentos($data)
    {
        $tramite_id = $data['tramite_id'] ?? null;
        $documentos = $data['documentos'] ?? [];
        $otro = $data['otro'] ?? null;
        if (!$tramite_id) {
            return ["success" => false, "message" => "tramite_id requerido", "data" => null];
        }
        $result = DB::select('SELECT * FROM sp_doctosfrm_save(:tramite_id, :documentos, :otro)', [
            "tramite_id" => $tramite_id,
            "documentos" => json_encode($documentos),
            "otro" => $otro
        ]);
        return ["success" => true, "message" => "Documentos guardados", "data" => $result];
    }

    /**
     * Limpiar documentos seleccionados para un trámite
     */
    private function clearDocumentos($data)
    {
        $tramite_id = $data['tramite_id'] ?? null;
        if (!$tramite_id) {
            return ["success" => false, "message" => "tramite_id requerido", "data" => null];
        }
        $result = DB::select('SELECT * FROM sp_doctosfrm_clear(:tramite_id)', ["tramite_id" => $tramite_id]);
        return ["success" => true, "message" => "Documentos limpiados", "data" => $result];
    }

    /**
     * Listar catálogo de documentos posibles
     */
    private function listDocumentos($data)
    {
        $docs = DB::select('SELECT * FROM sp_doctosfrm_catalog()');
        return ["success" => true, "message" => "Catálogo de documentos", "data" => $docs];
    }

    /**
     * Eliminar un documento específico de un trámite
     */
    private function deleteDocumento($data)
    {
        $tramite_id = $data['tramite_id'] ?? null;
        $documento = $data['documento'] ?? null;
        if (!$tramite_id || !$documento) {
            return ["success" => false, "message" => "tramite_id y documento requeridos", "data" => null];
        }
        $result = DB::select('SELECT * FROM sp_doctosfrm_delete(:tramite_id, :documento)', [
            "tramite_id" => $tramite_id,
            "documento" => $documento
        ]);
        return ["success" => true, "message" => "Documento eliminado", "data" => $result];
    }
}
