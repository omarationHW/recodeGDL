# Documentación Técnica: Migración Formulario Firmas (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la administración de las firmas que aparecen en los oficios de convenios. Incluye operaciones de alta, edición, consulta y eliminación de registros de firmas asociadas a cada recaudadora.

## 2. Arquitectura
- **Backend:** Laravel (PHP) con endpoint unificado `/api/execute`.
- **Frontend:** Vue.js (SPA, página independiente para Firmas).
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API Pattern:** eRequest/eResponse (action, data, entity).

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "list|create|update|delete|get",
    "entity": "firmas",
    "data": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "status": "success|error",
    "data": [ ... ],
    "message": "..."
  }
  ```

## 4. Stored Procedures
- **sp_firmas_list:** Devuelve todas las firmas.
- **sp_firmas_create:** Inserta una nueva firma.
- **sp_firmas_update:** Actualiza una firma existente.
- **sp_firmas_delete:** Elimina una firma por recaudadora.
- **sp_firmas_get:** Devuelve una firma específica.

## 5. Validaciones
- Todos los campos son obligatorios excepto letras (máx 3 caracteres).
- No se permite duplicidad de recaudadora.

## 6. Seguridad
- El endpoint debe estar protegido por autenticación JWT o sesión Laravel.
- Validar permisos de usuario antes de permitir operaciones de escritura.

## 7. Frontend (Vue.js)
- Página independiente `/firmas`.
- Tabla con selección de fila.
- Modal para alta/edición.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 8. Integración
- El frontend consume el endpoint `/api/execute` con el entity `firmas` y la acción correspondiente.
- El backend enruta la petición al stored procedure adecuado.

## 9. Ejemplo de llamada API
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'create',
    entity: 'firmas',
    data: {
      recaudadora: 1,
      titular: 'Juan Pérez',
      cargotitular: 'Director',
      recaudador: 'Ana López',
      cargorecaudador: 'Jefa de Recaudación',
      testigo1: 'Carlos Ruiz',
      testigo2: 'María Díaz',
      letras: 'ZC1'
    }
  })
})
```

## 10. Migración de lógica Delphi
- Los métodos de refresco, alta, edición y cierre se implementan como acciones API.
- La autorización se realiza en backend (middleware Laravel).
- El frontend replica la experiencia de usuario de Delphi pero en SPA.

## 11. Consideraciones
- El campo `letras` se utiliza para identificar la zona/recaudadora.
- El campo `recaudadora` es clave primaria.
- El frontend debe validar que todos los campos estén llenos antes de enviar.

## 12. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
