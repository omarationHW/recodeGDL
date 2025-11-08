# Documentación Técnica: Migración Formulario Menu (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL 13+, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse, siempre vía POST JSON.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "catalog.list.unidades",
      "params": { "ejercicio": 2024 }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "result": [ ... ],
      "error": null
    }
  }
  ```
- **Acciones soportadas**: `catalog.list.unidades`, `catalog.create.unidad`, `catalog.update.unidad`, `catalog.delete.unidad`, `catalog.list.tipos_aseo`, etc.

## 3. Stored Procedures
- Toda la lógica de negocio y validación reside en stored procedures (SPs) de PostgreSQL.
- Los SPs devuelven errores como filas con texto 'ERROR: ...' o lanzan excepciones.
- Los SPs CRUD para catálogos siguen el patrón:
  - `sp_cat_<entidad>_list([params])`
  - `sp_cat_<entidad>_create([params])`
  - `sp_cat_<entidad>_update([params])`
  - `sp_cat_<entidad>_delete([params])`
- Los reportes usan SPs tipo `sp_rep_<reporte>_export([params])`.

## 4. Frontend Vue.js
- Cada catálogo/consulta es una página Vue independiente.
- Navegación por rutas (ejemplo: `/catalogos/unidades`).
- Cada página implementa:
  - Breadcrumb de navegación.
  - Tabla de datos.
  - Modales para alta/edición.
  - Acciones CRUD conectadas al endpoint `/api/execute`.
- Manejo de errores y mensajes de usuario.

## 5. Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en backend y frontend.
- Los SPs validan integridad referencial (por ejemplo, no eliminar unidad con contratos asociados).

## 6. Ejemplo de Flujo CRUD (Unidades)
1. El usuario accede a la página de Unidades.
2. El frontend llama a `/api/execute` con acción `catalog.list.unidades` y el ejercicio seleccionado.
3. El backend ejecuta el SP correspondiente y retorna los datos.
4. Para crear, el frontend muestra un modal, el usuario llena los campos y envía acción `catalog.create.unidad`.
5. El backend ejecuta el SP de creación, valida duplicados y responde éxito o error.
6. Para editar/eliminar, se usan las acciones `catalog.update.unidad` y `catalog.delete.unidad`.

## 7. Extensibilidad
- Para agregar nuevos catálogos, reportes o procesos, basta con:
  - Crear el SP correspondiente en PostgreSQL.
  - Agregar el case en el controlador Laravel.
  - Crear la página Vue si aplica.

## 8. Notas de Migración
- Todos los formularios Delphi se migran a páginas independientes.
- No se usan tabs ni componentes tabulares.
- Los reportes/exportaciones se implementan como SPs y pueden ser consumidos por el frontend para descarga.
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones del sistema.
