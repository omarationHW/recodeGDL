<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class CargaImagenController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        try {
            switch ($action) {
                case 'getDocumentTypes':
                    return $this->getDocumentTypes();
                case 'getTramiteDocs':
                    return $this->getTramiteDocs($params);
                case 'getImages':
                    return $this->getImages($params);
                case 'uploadImage':
                    return $this->uploadImage($request, $params, $user);
                case 'deleteImage':
                    return $this->deleteImage($params, $user);
                case 'getTramiteInfo':
                    return $this->getTramiteInfo($params);
                default:
                    return response()->json(['error' => 'Acción no soportada'], 400);
            }
        } catch (\Exception $e) {
            Log::error('CargaImagenController error: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Obtener tipos de documentos
     */
    public function getDocumentTypes()
    {
        $types = DB::select('SELECT id, documento FROM c_doctos ORDER BY documento');
        return response()->json(['success' => true, 'data' => $types]);
    }

    /**
     * Obtener documentos asociados a un trámite
     */
    public function getTramiteDocs($params)
    {
        $tramiteId = $params['tramite_id'] ?? null;
        if (!$tramiteId) {
            return response()->json(['error' => 'tramite_id requerido'], 400);
        }
        $docs = DB::select('SELECT td.id_imagen, d.documento, td.id_licencia FROM tramitedocs td JOIN c_doctos d ON td.cvedocto = d.id WHERE td.id_tramite = ?', [$tramiteId]);
        return response()->json(['success' => true, 'data' => $docs]);
    }

    /**
     * Obtener imágenes de un documento
     */
    public function getImages($params)
    {
        $idImagen = $params['id_imagen'] ?? null;
        if (!$idImagen) {
            return response()->json(['error' => 'id_imagen requerido'], 400);
        }
        $image = DB::selectOne('SELECT imagen FROM digital_docs WHERE id_imagen = ?', [$idImagen]);
        if ($image && $image->imagen) {
            $base64 = base64_encode(stream_get_contents($image->imagen));
            return response()->json(['success' => true, 'data' => $base64]);
        }
        return response()->json(['error' => 'Imagen no encontrada'], 404);
    }

    /**
     * Subir imagen y asociarla a un trámite
     */
    public function uploadImage(Request $request, $params, $user)
    {
        $tramiteId = $params['tramite_id'] ?? null;
        $documentTypeId = $params['document_type_id'] ?? null;
        $file = $request->file('file');
        if (!$tramiteId || !$documentTypeId || !$file) {
            return response()->json(['error' => 'Parámetros requeridos: tramite_id, document_type_id, file'], 400);
        }
        // Validar extensión
        $ext = strtolower($file->getClientOriginalExtension());
        if (!in_array($ext, ['jpg', 'jpeg', 'tif', 'tiff', 'png'])) {
            return response()->json(['error' => 'Formato de archivo no permitido'], 400);
        }
        // Guardar en digital_docs
        $blob = fopen($file->getRealPath(), 'rb');
        $idImagen = DB::table('digital_docs')->insertGetId([
            'cvedocto' => $documentTypeId,
            'id_tramite' => $tramiteId,
            'imagen' => $blob,
            'feccap' => now(),
            'capturista' => $user ? $user->username : 'sistema',
        ]);
        // Insertar en tramitedocs
        DB::table('tramitedocs')->insert([
            'id_tramite' => $tramiteId,
            'id_imagen' => $idImagen,
            'id_licencia' => $params['id_licencia'] ?? null,
            'cvedocto' => $documentTypeId
        ]);
        return response()->json(['success' => true, 'id_imagen' => $idImagen]);
    }

    /**
     * Eliminar imagen/documento
     */
    public function deleteImage($params, $user)
    {
        $idImagen = $params['id_imagen'] ?? null;
        if (!$idImagen) {
            return response()->json(['error' => 'id_imagen requerido'], 400);
        }
        DB::beginTransaction();
        try {
            DB::table('tramitedocs')->where('id_imagen', $idImagen)->delete();
            DB::table('digital_docs')->where('id_imagen', $idImagen)->delete();
            DB::commit();
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Obtener información básica del trámite
     */
    public function getTramiteInfo($params)
    {
        $tramiteId = $params['tramite_id'] ?? null;
        if (!$tramiteId) {
            return response()->json(['error' => 'tramite_id requerido'], 400);
        }
        $info = DB::selectOne('SELECT id_tramite, cvecuenta, recaud FROM tramites WHERE id_tramite = ?', [$tramiteId]);
        return response()->json(['success' => true, 'data' => $info]);
    }
}
