# Documentación Técnica: Migración de Formulario GruposLicenciasAbcfrm a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la administración de los grupos de licencias (catálogo `lic_grupos`) mediante una API unificada, frontend Vue.js y lógica de negocio en stored procedures PostgreSQL. Incluye operaciones de alta, modificación, consulta, filtrado y eliminación.

## 2. Arquitectura
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "operation": "nombre_operacion",
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": ..., // resultado de la operación
      "message": "mensaje de error o éxito"
    }
  }
  ```

### Operaciones soportadas
- `list_grupos_licencias` (params: { descripcion })
- `get_grupo_licencia` (params: { id })
- `insert_grupo_licencia` (params: { descripcion })
- `update_grupo_licencia` (params: { id, descripcion })
- `delete_grupo_licencia` (params: { id })

## 4. Stored Procedures
Toda la lógica de acceso y manipulación de datos reside en funciones PL/pgSQL:
- **sp_list_grupos_licencias:** Listado y filtrado por descripción.
- **sp_get_grupo_licencia:** Consulta por ID.
- **sp_insert_grupo_licencia:** Alta de grupo.
- **sp_update_grupo_licencia:** Modificación de grupo.
- **sp_delete_grupo_licencia:** Eliminación de grupo.

## 5. Frontend Vue.js
- Página independiente `/grupos-licencias`.
- Tabla con listado y filtro por descripción.
- Formulario modal para alta/modificación.
- Acciones: agregar, editar, eliminar.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de campos en frontend y backend.
- Uso de parámetros en las llamadas a stored procedures (previene SQL Injection).
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 7. Consideraciones
- El campo `id` es autoincremental y no editable en edición.
- El campo `descripcion` se almacena en mayúsculas y es obligatorio.
- El filtrado es insensible a mayúsculas/minúsculas (ILIKE).

## 8. Instalación y Despliegue
1. Crear la tabla `lic_grupos` en PostgreSQL si no existe:
   ```sql
   CREATE TABLE lic_grupos (
     id SERIAL PRIMARY KEY,
     descripcion VARCHAR(255) NOT NULL
   );
   ```
2. Crear los stored procedures proporcionados.
3. Configurar el endpoint `/api/execute` en Laravel y registrar el controlador.
4. Integrar el componente Vue.js en la SPA y configurar la ruta.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
