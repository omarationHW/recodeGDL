# Documentación Técnica: Migración Formulario propuestatab1 (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada sección/formulario es una página independiente)
- **Base de Datos:** PostgreSQL (todas las operaciones encapsuladas en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (entrada y salida JSON)

## Flujo de Datos
1. **Frontend** solicita datos o acciones mediante POST a `/api/execute` con un objeto `eRequest` que indica la acción y los parámetros.
2. **Laravel Controller** recibe la petición, despacha la acción al stored procedure correspondiente y retorna la respuesta en `eResponse`.
3. **Stored Procedures** en PostgreSQL encapsulan toda la lógica de negocio y acceso a datos.
4. **Frontend** muestra los datos en páginas independientes, cada una con su propia ruta y lógica.

## Endpoints y Acciones
- `/api/execute` (POST)
  - `action`: string (ej: 'list', 'show', 'create', 'update', 'delete', 'history', 'regimen', 'valores', 'pagos', 'diferencias', 'obs400', 'cfs400', 'escrituras', 'condominio')
  - `params`: objeto con los parámetros requeridos por la acción

## Stored Procedures
- Cada acción relevante tiene su propio stored procedure, siguiendo la convención `propuestatab1_<acción>`.
- Todos los SP devuelven datos en formato tabla (para fácil consumo por Laravel y Vue).
- Los SP de CRUD reciben parámetros simples o JSON según el caso.

## Frontend (Vue.js)
- Cada sección/tab del formulario Delphi original es ahora una página Vue independiente.
- El componente principal permite buscar una cuenta y navegar entre las páginas de detalle.
- Cada página Vue hace su propia llamada a `/api/execute` con la acción correspondiente.
- No se usan tabs ni componentes tabulares; cada sección es una ruta/página.

## Seguridad
- Todas las operaciones deben ser autenticadas (middleware Laravel, no incluido aquí).
- Validación de datos en backend y frontend.

## Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "show",
    "params": { "cvecuenta": 12345 }
  }
}
```
Respuesta:
```json
{
  "eResponse": {
    "success": true,
    "data": [ { ... } ],
    "message": ""
  }
}
```

## Consideraciones de Migración
- Todos los queries SQL y lógica de negocio Delphi se migran a stored procedures.
- El frontend Vue.js es desacoplado y consume la API vía Axios.
- El backend Laravel es un simple despachador de acciones.
- El modelo de datos debe estar previamente migrado a PostgreSQL.

## Extensibilidad
- Para agregar nuevas acciones, basta con crear el SP y agregar el case correspondiente en el controlador Laravel.
- El frontend puede agregar nuevas páginas fácilmente.

