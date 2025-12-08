# Documentación Técnica: carga_imagen

## Análisis Técnico

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

## Casos de Prueba

# Casos de Prueba para Carga de Imagen

## 1. Subida exitosa de documento
- **Precondición**: El usuario tiene permisos y el trámite existe.
- **Acción**: Subir archivo JPG válido.
- **Resultado esperado**: Respuesta success, documento aparece en la lista.

## 2. Subida de archivo con extensión no permitida
- **Precondición**: El usuario intenta subir un archivo .exe
- **Acción**: Subir archivo .exe
- **Resultado esperado**: Error de validación, mensaje 'Formato de archivo no permitido'.

## 3. Visualización de documento existente
- **Precondición**: Existe documento asociado.
- **Acción**: Solicitar imagen por id_imagen
- **Resultado esperado**: Respuesta con base64, imagen visible en modal.

## 4. Eliminación de documento
- **Precondición**: Documento existe y usuario tiene permisos
- **Acción**: Eliminar documento
- **Resultado esperado**: Respuesta success, documento ya no aparece en la lista.

## 5. Intento de eliminar documento inexistente
- **Precondición**: id_imagen no existe
- **Acción**: Eliminar documento
- **Resultado esperado**: Error 404, mensaje 'Imagen no encontrada'.

## 6. Consulta de tipos de documentos
- **Acción**: getDocumentTypes
- **Resultado esperado**: Lista de tipos de documentos disponibles.

## 7. Consulta de documentos de trámite inexistente
- **Acción**: getTramiteDocs con tramite_id inválido
- **Resultado esperado**: Lista vacía o error de trámite no encontrado.

## Casos de Uso

# Casos de Uso - carga_imagen

**Categoría:** Form

## Caso de Uso 1: Subir un documento escaneado a un trámite

**Descripción:** El usuario necesita asociar un documento escaneado (por ejemplo, comprobante de domicilio) al trámite 1234.

**Precondiciones:**
El usuario está autenticado y tiene permisos para modificar el trámite.

**Pasos a seguir:**
1. El usuario accede a la página de documentos del trámite 1234.
2. Hace clic en 'Agregar documento'.
3. Selecciona 'Comprobante de domicilio' como tipo de documento.
4. Selecciona el archivo 'comprobante.jpg' desde su computadora.
5. Hace clic en 'Subir'.
6. El sistema valida y guarda el documento.

**Resultado esperado:**
El documento aparece en la lista de documentos asociados al trámite. Puede ser visualizado y eliminado.

**Datos de prueba:**
tramite_id: 1234, document_type_id: 2, file: comprobante.jpg

---

## Caso de Uso 2: Visualizar un documento previamente cargado

**Descripción:** El usuario desea ver el documento 'INE.jpg' asociado al trámite 1234.

**Precondiciones:**
El documento ya fue cargado y está asociado al trámite.

**Pasos a seguir:**
1. El usuario accede a la página de documentos del trámite 1234.
2. En la lista, localiza el documento 'INE'.
3. Hace clic en 'Ver'.

**Resultado esperado:**
Se abre una ventana modal mostrando la imagen escaneada.

**Datos de prueba:**
tramite_id: 1234, id_imagen: 888

---

## Caso de Uso 3: Eliminar un documento asociado por error

**Descripción:** El usuario subió por error un documento equivocado y desea eliminarlo.

**Precondiciones:**
El usuario tiene permisos de eliminación y el documento no está bloqueado.

**Pasos a seguir:**
1. El usuario accede a la página de documentos del trámite 1234.
2. En la lista, localiza el documento equivocado.
3. Hace clic en 'Eliminar'.
4. Confirma la eliminación.

**Resultado esperado:**
El documento desaparece de la lista y ya no puede ser visualizado.

**Datos de prueba:**
tramite_id: 1234, id_imagen: 777

---

