# Documentación Técnica: Migración de sDM_Procesos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la gestión de la entidad **Procesos** en la base de datos `BasePHP`, migrando la lógica de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (almacenamiento y lógica de negocio).

## 2. Estructura de la Base de Datos
Se asume la existencia de la tabla:

```sql
CREATE TABLE procesos (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  descripcion TEXT
);
```

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Patrón:** eRequest/eResponse
- **Métodos soportados:**
  - `list`: Listar todos los procesos
  - `get`: Obtener un proceso por ID
  - `create`: Crear un nuevo proceso
  - `update`: Actualizar un proceso existente
  - `delete`: Eliminar un proceso

### Ejemplo de Request
```json
{
  "eRequest": {
    "action": "create",
    "data": {
      "nombre": "Proceso X",
      "descripcion": "Descripción del proceso X"
    }
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "message": "",
    "data": {
      "id": 1,
      "nombre": "Proceso X",
      "descripcion": "Descripción del proceso X"
    }
  }
}
```

## 4. Stored Procedures
Toda la lógica de acceso y manipulación de datos se realiza mediante funciones almacenadas en PostgreSQL:
- `procesos_listar()`
- `procesos_obtener(p_id)`
- `procesos_crear(p_nombre, p_descripcion)`
- `procesos_actualizar(p_id, p_nombre, p_descripcion)`
- `procesos_eliminar(p_id)`

## 5. Laravel Controller
- Controlador: `ProcesosController`
- Método principal: `execute(Request $request)`
- Utiliza el endpoint `/api/execute` para todas las operaciones.
- Valida y enruta la acción solicitada, invocando los stored procedures correspondientes.

## 6. Vue.js Component
- Página independiente: `ProcesosPage.vue`
- Permite listar, crear, editar y eliminar procesos.
- Utiliza el endpoint `/api/execute` para todas las operaciones.
- Incluye navegación breadcrumb y mensajes de usuario.

## 7. Seguridad
- Validación básica de campos obligatorios en backend y frontend.
- Se recomienda agregar autenticación y autorización según el contexto de la aplicación.

## 8. Consideraciones
- El endpoint es unificado para facilitar la integración y el mantenimiento.
- El frontend es completamente funcional como página independiente.
- La lógica de negocio reside en los stored procedures para facilitar la migración y el mantenimiento.
