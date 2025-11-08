# Catálogo de Requisitos (CatRequisitos)

## Descripción General
Este módulo permite la administración del catálogo de requisitos para giros comerciales. Incluye operaciones de alta, edición, eliminación, búsqueda y listado, así como la impresión del catálogo. La solución está compuesta por:

- **Backend Laravel**: Controlador único que expone un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend Vue.js**: Componente de página independiente para la gestión de requisitos.
- **Base de Datos PostgreSQL**: Lógica de negocio encapsulada en stored procedures.

## Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante un único endpoint POST `/api/execute`.
- **Patrón eRequest/eResponse**: El frontend envía un objeto `eRequest` con los parámetros de acción y datos. El backend responde con `eResponse`.
- **Stored Procedures**: Toda la lógica de acceso y manipulación de datos reside en funciones SQL (PostgreSQL).

## Flujo de Operación
1. El usuario accede a la página de Catálogo de Requisitos.
2. Vue.js carga el listado de requisitos mediante `action: list`.
3. El usuario puede buscar, agregar, editar o eliminar requisitos:
   - **Agregar**: Abre formulario, envía `action: create`.
   - **Editar**: Abre formulario con datos, envía `action: update`.
   - **Eliminar**: Confirma y envía `action: delete`.
   - **Buscar**: Envía `action: search` con el texto.
   - **Imprimir**: Muestra listado para impresión (puede exportar a PDF desde el navegador).
4. Todas las acciones se comunican vía `/api/execute`.

## Seguridad
- Validación de datos en backend (Laravel Validator).
- Solo se permite manipulación de campos permitidos.
- El endpoint puede protegerse con middleware de autenticación si es necesario.

## Integración
- El componente Vue.js puede integrarse en cualquier SPA o sistema de rutas.
- El backend puede ser extendido para auditar cambios o agregar logs.

## Consideraciones
- El campo `req` es autoincremental (no serial, sino calculado como MAX+1 para compatibilidad con el sistema original).
- La eliminación es física (no lógica), pero puede adaptarse a soft-delete si se requiere.
- El listado para impresión es el mismo que el listado general.

## Ejemplo de eRequest/eResponse

### Solicitud (Agregar requisito)
```json
{
  "eRequest": {
    "module": "cat_requisitos",
    "action": "create",
    "data": {
      "descripcion": "Copia de identificación oficial vigente"
    }
  }
}
```

### Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": { "req": 12, "descripcion": "Copia de identificación oficial vigente" },
    "message": ""
  }
}
```

## Estructura de la Tabla

```sql
CREATE TABLE c_girosreq (
  req integer PRIMARY KEY,
  descripcion varchar(255) NOT NULL
);
```

## API
- **/api/execute** (POST)
  - Entrada: `{ eRequest: { module: 'cat_requisitos', action: 'list|search|create|update|delete|print', data: {...} } }`
  - Salida: `{ eResponse: { success, data, message } }`

## Validaciones
- Descripción: Obligatoria, máximo 255 caracteres.
- Número de requisito: Solo para edición/eliminación.

## Extensibilidad
- Puede integrarse con otros módulos de catálogos.
- Puede auditarse con triggers o logs en base de datos.
