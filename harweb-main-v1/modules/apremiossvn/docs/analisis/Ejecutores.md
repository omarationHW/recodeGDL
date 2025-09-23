# Documentación Técnica: Migración Formulario Ejecutores (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la consulta de ejecutores, migrado desde Delphi a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (con stored procedures). El formulario permite filtrar ejecutores por nombre o clave y visualizar sus datos en una tabla.

## 2. Arquitectura
- **Backend**: Laravel Controller expone un endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs, con filtros y tabla de resultados.
- **Base de Datos**: Toda la lógica de consulta encapsulada en stored procedures PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "listar|buscar_nombre|buscar_cve", "params": { ... } } }`
- **Salida**: `{ "eResponse": { "success": true|false, "data": [...], "message": "" } }`

### Acciones soportadas
- `listar`: Lista todos los ejecutores activos.
- `buscar_nombre`: Busca ejecutores por nombre parcial.
- `buscar_cve`: Busca ejecutores por clave parcial.

## 4. Stored Procedures
- **sp_ejecutores_listar**: Lista ejecutores activos.
- **sp_ejecutores_buscar_nombre**: Busca ejecutores por nombre (parcial, insensible a mayúsculas/minúsculas).
- **sp_ejecutores_buscar_cve**: Busca ejecutores por clave (parcial).

## 5. Validaciones
- El filtro de clave solo permite números y máximo 5 dígitos.
- El filtro de nombre convierte a mayúsculas automáticamente.

## 6. Frontend
- Página Vue.js con breadcrumb, filtros y tabla.
- Botón Cancelar regresa a la página anterior.
- La tabla muestra: Cve Ejecutor, Nombre, ID Rec, RFC Inicial, RFC Fecha, RFC Homoclave.

## 7. Seguridad
- El endpoint debe protegerse con autenticación (no incluida aquí, pero recomendada para producción).

## 8. Consideraciones
- El SP de búsqueda por nombre usa `unaccent` y `upper` para búsquedas insensibles a acentos y mayúsculas/minúsculas (requiere extensión `unaccent` en PostgreSQL).
- El SP de búsqueda por clave permite búsqueda parcial (ej: "12" encuentra "12345").

## 9. Instalación
- Crear los stored procedures en la base de datos `BasePHP`.
- Registrar la ruta en Laravel:
  ```php
  Route::post('/api/execute', [\App\Http\Controllers\Api\EjecutoresController::class, 'execute']);
  ```
- Incluir el componente Vue.js en el router de la SPA.

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.
