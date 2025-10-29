# Documentación Técnica: Migración Formulario doctosfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "doctosfrm" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite seleccionar documentos requeridos para un trámite, guardar la selección, limpiar, y agregar un documento personalizado ("Otro").

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación propia.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Todas las operaciones (get, save, clear, list, delete) se realizan mediante el endpoint `/api/execute`.

## 3. Modelo de Datos
Tabla sugerida para almacenar la selección de documentos:

```sql
CREATE TABLE doctosfrm_tramite (
  tramite_id integer PRIMARY KEY,
  documentos text[], -- array de códigos de documentos
  otro text
);
```

## 4. Stored Procedures
- `sp_doctosfrm_catalog()`: Devuelve el catálogo de documentos posibles.
- `sp_doctosfrm_get(tramite_id)`: Devuelve los documentos seleccionados para un trámite.
- `sp_doctosfrm_save(tramite_id, documentos, otro)`: Guarda la selección de documentos.
- `sp_doctosfrm_clear(tramite_id)`: Limpia la selección de documentos.
- `sp_doctosfrm_delete(tramite_id, documento)`: Elimina un documento específico de la selección.

## 5. API (Laravel Controller)
- **Ruta:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "get|save|clear|list|delete",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 6. Frontend (Vue.js)
- Página independiente (no tab), ruta sugerida `/tramites/:tramite_id/documentos`.
- Carga el catálogo de documentos al montar.
- Si existe `tramite_id` en la ruta, carga la selección previa.
- Permite seleccionar/deseleccionar documentos, agregar "Otro", limpiar y guardar.
- Botón cancelar regresa a la página anterior.

## 7. Seguridad y Validaciones
- El backend valida que `tramite_id` esté presente en todas las operaciones.
- El frontend muestra mensajes de error si falta algún dato requerido.
- Todas las operaciones usan transacciones y manejo de errores.

## 8. Extensibilidad
- El catálogo de documentos puede ampliarse fácilmente en el SP `sp_doctosfrm_catalog`.
- El modelo permite agregar más campos si se requieren metadatos adicionales.

## 9. Integración
- El endpoint `/api/execute` puede ser consumido por cualquier frontend SPA o móvil.
- El patrón eRequest/eResponse permite unificar la API para otros formularios.

## 10. Ejemplo de Payloads
- **Guardar selección:**
  ```json
  {
    "eRequest": {
      "action": "save",
      "data": {
        "tramite_id": 123,
        "documentos": ["fotofachada", "recibopredial"],
        "otro": "Carta de recomendación"
      }
    }
  }
  ```
- **Obtener selección:**
  ```json
  {
    "eRequest": {
      "action": "get",
      "data": { "tramite_id": 123 }
    }
  }
  ```

## 11. Notas de Migración
- El formulario Delphi usaba variables globales y lógica procedural; en la migración, toda la lógica se encapsula en SPs y el controlador.
- El campo "Otro" se maneja como texto libre y sólo se muestra si el checkbox correspondiente está marcado.
- El frontend es reactivo y refleja el estado de la base de datos en tiempo real.

## 12. Pruebas y QA
- Se recomienda probar todos los flujos: guardar, limpiar, eliminar, cargar selección previa, y agregar documento personalizado.
- El endpoint y los SPs deben ser cubiertos por pruebas unitarias y de integración.
