# Documentación Técnica: Migración de Formulario Carga de Imagen (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel (PHP 8+), PostgreSQL 13+
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **API**: Endpoint único `/api/execute` que recibe eRequest con acción y parámetros, responde con eResponse JSON.
- **Almacenamiento de Imágenes**: En tabla `digital_docs` (campo tipo bytea en PostgreSQL)
- **Seguridad**: Autenticación Laravel Sanctum/JWT recomendada, validación de usuario en cada acción.

## 2. Flujo de Trabajo
1. El usuario accede a la página de documentos asociados a un trámite.
2. El frontend consulta los tipos de documentos (`getDocumentTypes`).
3. El frontend consulta los documentos ya asociados al trámite (`getTramiteDocs`).
4. El usuario puede subir un nuevo documento (imagen) seleccionando tipo y archivo (`uploadImage`).
5. El usuario puede ver la imagen (descarga base64 vía `getImages`).
6. El usuario puede eliminar un documento (`deleteImage`).

## 3. API Backend (Laravel)
- **Endpoint**: `/api/execute` (POST)
- **Body**:
  ```json
  {
    "action": "nombreAccion",
    "params": { ... },
    // Si es uploadImage, se usa FormData
  }
  ```
- **Acciones soportadas**:
  - `getDocumentTypes`: Lista tipos de documentos
  - `getTramiteDocs`: Lista documentos de un trámite
  - `getImages`: Devuelve imagen base64
  - `uploadImage`: Sube imagen (requiere FormData)
  - `deleteImage`: Elimina documento
  - `getTramiteInfo`: Info básica del trámite

## 4. Stored Procedures PostgreSQL
- Toda la lógica SQL se encapsula en funciones PL/pgSQL:
  - `sp_get_document_types()`
  - `sp_get_tramite_docs(p_tramite_id)`
  - `sp_get_image(p_id_imagen)`
  - `sp_upload_image(p_tramite_id, p_document_type_id, p_id_licencia, p_file, p_capturista)`
  - `sp_delete_image(p_id_imagen)`
  - `sp_get_tramite_info(p_tramite_id)`
- Todas las operaciones de inserción/eliminación son transaccionales.

## 5. Frontend (Vue.js)
- Página independiente `/tramites/:tramiteId/documentos`
- Muestra lista de documentos, permite agregar, ver y eliminar.
- Subida de archivos vía FormData (multipart/form-data)
- Visualización de imágenes en modal (base64)
- Validación de formatos permitidos (.jpg, .tif, .png)

## 6. Seguridad y Validaciones
- El backend valida que el usuario tenga permisos para subir/eliminar documentos.
- El backend valida extensiones y tamaño de archivo.
- El frontend muestra mensajes claros de error.

## 7. Consideraciones de Migración
- El flujo de directorios y unidades de red de Delphi se reemplaza por almacenamiento en base de datos.
- El control de tipos de documento y asociación a trámite se mantiene.
- El control de usuario/capturista se obtiene del contexto de autenticación Laravel.

## 8. Integración con otros módulos
- El endpoint `/api/execute` puede ser usado por otros formularios para asociar documentos a trámites de licencias, anuncios, etc.
- El identificador de trámite es el parámetro clave para la asociación.

## 9. Ejemplo de eRequest/eResponse
### eRequest para subir imagen:
```json
{
  "action": "uploadImage",
  "params": {
    "tramite_id": 1234,
    "document_type_id": 2,
    "id_licencia": 5678
  },
  "file": "(archivo binario)"
}
```
### eResponse:
```json
{
  "success": true,
  "id_imagen": 999
}
```

## 10. Manejo de Errores
- Todos los errores se devuelven en formato JSON con campo `error`.
- El frontend debe mostrar el mensaje y permitir reintentar.

---
