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
