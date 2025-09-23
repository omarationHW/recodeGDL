# Documentación Técnica: Consulta de Contratos (ConsContratos)

## Descripción General
Este módulo permite consultar contratos de obra pública por diferentes criterios: por número de contrato (colonia, calle, folio), por nombre del titular o por domicilio (descripción de calle y número). Permite visualizar el detalle completo de cada contrato.

La solución está compuesta por:
- Un controlador Laravel que expone un endpoint único `/api/execute` bajo el patrón eRequest/eResponse.
- Un componente Vue.js que implementa la interfaz de usuario como página independiente.
- Stored Procedures en PostgreSQL para encapsular la lógica de consulta.
- Documentación, casos de uso y pruebas.

## API Backend (Laravel)
- **Endpoint:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "action": "searchByContrato|searchByNombre|searchByDomicilio|getContratoDetalle",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": ""
  }
  ```
- **Acciones soportadas:**
  - `searchByContrato`: Busca por colonia, calle, folio (mínimo)
  - `searchByNombre`: Busca por nombre (LIKE)
  - `searchByDomicilio`: Busca por descripción de calle y número (LIKE)
  - `getContratoDetalle`: Devuelve todos los datos de un contrato por su id

## Stored Procedures (PostgreSQL)
- Toda la lógica de consulta está encapsulada en funciones tipo `RETURNS TABLE`.
- Se recomienda crear índices en los campos de búsqueda frecuentes (colonia, calle, folio, nombre, desc_calle, numero).

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar el tipo de búsqueda y muestra los resultados en tabla.
- Permite ver el detalle completo de un contrato en un panel aparte.
- Usa fetch API para comunicarse con `/api/execute`.

## Validaciones
- Los campos de búsqueda tienen longitud máxima y validación básica.
- El backend valida tipos y existencia de parámetros.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Los stored procedures no permiten SQL injection (parámetros tipados).

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para incluir joins o filtros adicionales.

# Diagrama de Flujo
1. Usuario selecciona tipo de búsqueda y llena campos.
2. Vue.js envía petición a `/api/execute` con acción y parámetros.
3. Laravel Controller ejecuta el stored procedure correspondiente.
4. Se devuelven los resultados y se muestran en la tabla.
5. Al seleccionar un contrato, se muestra el detalle completo.

# Consideraciones de Migración
- Los nombres de campos y tablas deben coincidir con la estructura de PostgreSQL.
- Los stored procedures reemplazan la lógica SQL dinámica de Delphi.
- El endpoint único facilita la integración con otros módulos.

# Requerimientos
- PHP 8+, Laravel 9+
- Vue.js 3+
- PostgreSQL 13+

# Ejemplo de Request
```json
{
  "action": "searchByContrato",
  "params": { "colonia": 1, "calle": 2, "folio": 100 }
}
```

# Ejemplo de Response
```json
{
  "success": true,
  "data": [ { "id_convenio": 123, "colonia": 1, ... } ],
  "message": ""
}
```
