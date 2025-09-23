# Documentación Técnica - Migración ListadoMultiple Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 (Composition API), componente de página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las acciones se resuelven por un único endpoint y un parámetro `action`.

## 2. Endpoints API
- **POST /api/execute**
  - **action**: Nombre de la acción a ejecutar (ej: `getConveniosEmpresas`)
  - **params**: Objeto con parámetros específicos de la acción
  - **Respuesta**: JSON con `success`, `data` y/o `message`

## 3. Stored Procedures
- Toda la lógica SQL se encapsula en funciones PostgreSQL (tipo `RETURNS TABLE`), por ejemplo:
  - `conveniosempresas(paxo, pfecha)`
  - `pagos_convenios_empresas(pejec, pftrab, pfpagod, pfpagoh)`
  - `get_ejecutores_empresas(ftrabajo)`
- Las vistas como `conveniosempresas_view` y `pagos_convenios_empresas_view` deben existir y contener la lógica de joins/filters.

## 4. Controlador Laravel
- Un solo método `execute(Request $request)` que despacha según el parámetro `action`.
- Cada acción llama a un stored procedure o consulta SQL.
- Validación básica de parámetros.
- Soporta exportación a Excel (puede ser implementado en backend o frontend).

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Formulario para búsqueda de convenios por año y fecha.
- Tabla de resultados de convenios.
- Formulario para búsqueda de pagos por ejecutor y rango de fechas.
- Tabla de resultados de pagos.
- Botones para exportar a Excel (placeholder, requiere implementación real).
- Uso de Composition API y axios para llamadas API.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: Sanctum, JWT) si es necesario.
- Validar que los parámetros sean correctos y que el usuario tenga permisos.

## 7. Consideraciones de Migración
- Los stored procedures Delphi/Informix deben ser reescritos en PostgreSQL.
- Los nombres de tablas y campos pueden requerir ajuste según el modelo relacional.
- Las vistas deben ser creadas para encapsular la lógica de joins y filtros complejos.
- El frontend debe ser SPA, cada formulario es una página independiente.

## 8. Exportación a Excel
- Puede implementarse en backend (Laravel Excel) o frontend (js-xlsx, SheetJS).
- El endpoint puede devolver un archivo o un link temporal.

## 9. Pruebas y Validación
- Se deben crear casos de uso y pruebas unitarias/integración para cada escenario.

## 10. Ejemplo de eRequest/eResponse
```json
{
  "action": "getConveniosEmpresas",
  "params": { "year": 2024, "fecha": "2024-06-01" }
}
```

## 11. Extensibilidad
- Para agregar nuevas acciones, solo se requiere agregar un case en el controlador y el stored procedure correspondiente.

