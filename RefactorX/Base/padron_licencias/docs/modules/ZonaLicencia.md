# Documentación Técnica: Migración Formulario ZonaLicencia (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la actualización de la zona, subzona y recaudadora asociada a una licencia municipal. El formulario original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), utilizando un endpoint API unificado y stored procedures para la lógica de negocio.

## 2. Arquitectura
- **Backend:** Laravel 10+, con un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente (no tabs).
- **Base de datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": ...
  }
  ```

### Acciones soportadas
- `get_zonas`: Listado de zonas para una recaudadora
- `get_subzonas`: Listado de subzonas para una zona y recaudadora
- `get_recaudadoras`: Listado de recaudadoras
- `get_licencia`: Datos de una licencia
- `get_licencias_zona`: Zona/subzona/recaudadora de una licencia
- `save_licencias_zona`: Guardar/actualizar zona/subzona/recaudadora de una licencia

## 4. Stored Procedures
Toda la lógica de consulta y actualización se implementa en funciones PL/pgSQL, ver sección `stored_procedures`.

## 5. Seguridad
- El endpoint requiere autenticación JWT (o similar).
- El usuario autenticado se utiliza como `capturista` en los cambios.
- Validación de parámetros en backend y frontend.

## 6. Frontend (Vue.js)
- Página independiente `/zona-licencia`.
- Formulario con campos: Licencia, Zona, Subzona, Recaudadora.
- Al ingresar la licencia, se cargan los datos actuales y se precargan los valores de zona/subzona/recaudadora si existen.
- Al guardar, se llama a la acción `save_licencias_zona`.
- Mensajes de éxito/error y validación de campos.

## 7. Backend (Laravel)
- Controlador único `ZonaLicenciaController`.
- Métodos para cada acción, usando DB::select/insert/update.
- Uso de transacciones y manejo de errores.

## 8. Base de Datos
- Tablas involucradas: `licencias`, `licencias_zona`, `c_zonas`, `c_subzonas`, `c_recaud`, `c_zonayrec`.
- Índices en campos clave.

## 9. Pruebas y Casos de Uso
Ver secciones `use_cases` y `test_cases`.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados.

## 11. Consideraciones
- El frontend puede ser adaptado a cualquier framework SPA.
- El backend puede ser extendido para auditoría, logging, y control de permisos.
