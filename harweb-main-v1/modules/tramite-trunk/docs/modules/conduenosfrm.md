# Documentación Técnica: Catálogo de Condueños (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse (entrada/salida JSON).

## 2. API Unificada
- **Endpoint**: `POST /api/execute`
- **Entrada**:
  ```json
  {
    "eRequest": {
      "operation": "list|create|update|delete|show|porcentajes|restore|history|validate_rfc|add_colonia|...",
      "data": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": null|string
    }
  }
  ```
- **Operaciones soportadas**: CRUD, reportes, validaciones, procesos especiales.

## 3. Stored Procedures
- Toda la lógica de negocio y validación reside en funciones/procedimientos de PostgreSQL.
- Ejemplo: `condueños_list`, `condueños_create`, `condueños_update`, `condueños_delete`, `condueños_porcentajes`, etc.
- Los procedimientos reciben parámetros y devuelven tablas o resultados según el caso.

## 4. Controlador Laravel
- Un solo controlador (`CondueñosController`) maneja todas las operaciones.
- Utiliza `DB::select` para invocar los stored procedures.
- Valida la operación y parámetros.
- Devuelve siempre el formato eResponse.

## 5. Componente Vue.js
- Cada formulario es una página Vue independiente.
- El listado muestra todos los condueños de la cuenta, con acciones para editar, eliminar, restaurar, historial.
- El formulario de edición/alta es una página separada.
- El cálculo de porcentajes se muestra en la misma página, con validación visual (rojo si ≠ 100%).
- Navegación por breadcrumbs.
- Uso de Axios para consumir el endpoint `/api/execute`.

## 6. Validaciones y Reglas de Negocio
- Solo puede haber un condueño con `encabeza = 'S'` y debe haber al menos uno.
- La suma de porcentajes debe ser exactamente 100%.
- No puede haber dos condueños con calidad 'PROPIETARIO'.
- El RFC debe ser único (excepto para el mismo contribuyente).
- La eliminación es lógica (vigencia = 'C'), la restauración reactiva el registro.

## 7. Seguridad
- Todas las operaciones requieren autenticación JWT (middleware Laravel, no mostrado aquí).
- Los procedimientos validan los parámetros y el usuario que realiza la operación.

## 8. Migración de Datos
- Los datos de las tablas Delphi deben migrarse a las tablas PostgreSQL equivalentes.
- Los procedimientos asumen que las tablas ya existen y tienen los campos necesarios.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin cambiar la API.
- Los formularios Vue pueden extenderse fácilmente para nuevos campos o reglas.

## 10. Ejemplo de llamada desde frontend
```js
axios.post('/api/execute', {
  eRequest: {
    operation: 'create',
    data: {
      cvecuenta: 12345,
      nombre_completo: 'JUAN PEREZ',
      rfc: 'PEJJ800101XXX',
      porcentaje: 50,
      encabeza: 'S',
      exento: 'N',
      usuario: 'admin'
    }
  }
});
```

## 11. Manejo de errores
- Todos los errores de validación o ejecución se devuelven en el campo `error` de la respuesta.
- El frontend debe mostrar los mensajes de error al usuario.

## 12. Pruebas y Auditoría
- Todas las operaciones quedan registradas en las tablas con campos de auditoría (`feccap`, `capturista`).
- El historial de cambios puede consultarse con la operación `history`.
