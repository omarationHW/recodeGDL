# Documentación Técnica: Migración Formulario ReqTrans (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Patrón de integración**: eRequest/eResponse (entrada y salida JSON).

## Endpoint Unificado
- **Ruta**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "list|show|create|update|delete|catalog|folio|folio_data", ...params } }`
- **Salida**: `{ "eResponse": { ... } }`

## Controlador Laravel
- Un solo controlador (`ReqTransController`) maneja todas las acciones.
- Cada acción del frontend se traduce en un `action` en el JSON de entrada.
- El controlador invoca los stored procedures según la acción.
- Validación de datos con Laravel Validator.
- Manejo de errores y respuestas unificadas.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio (alta, edición, baja, catálogos, consulta de folios) está en funciones/procedimientos almacenados.
- Los procedimientos devuelven datos o booleanos según corresponda.
- Se recomienda usar transacciones para operaciones críticas.

## Componente Vue.js
- Página independiente para ReqTrans.
- Formulario de captura con validación básica.
- Consulta de ejecutores vía API.
- Búsqueda de requerimientos por folio.
- Presentación de resultados y catálogo.
- Navegación y UX amigable.

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de roles/usuarios para acciones críticas.
- Sanitización de entrada y salida.

## Consideraciones de Migración
- Los combos y catálogos Delphi se migran a catálogos vía API.
- Los cálculos de totales y validaciones de fechas se hacen en el frontend y/o backend según corresponda.
- Los triggers Delphi se migran a lógica en SPs o validaciones en backend.

## Flujo de Datos
1. El usuario accede a la página de ReqTrans.
2. El frontend carga el catálogo de ejecutores vía `/api/execute` con `action: catalog`.
3. El usuario captura los datos y guarda (POST a `/api/execute` con `action: create`).
4. El backend ejecuta el SP correspondiente y responde con el resultado.
5. Para búsquedas, el frontend envía `action: list` o `action: show`.

## Ejemplo de Request/Response
### Crear:
```json
POST /api/execute
{
  "eRequest": {
    "action": "create",
    "folioreq": 1234,
    "tipo": "N",
    ...
  }
}
```

### Respuesta:
```json
{
  "eResponse": {
    "success": true,
    "message": "Registro creado",
    "id": 55
  }
}
```

## Validaciones
- Fechas no pueden ser futuras.
- Importe, recargos, multas, gastos >= 0.
- Folio debe existir en transmisión.
- Usuario debe estar autenticado.

## Notas
- El endpoint `/api/execute` puede ser extendido para otras acciones y catálogos.
- Los stored procedures pueden ser versionados y auditados.
- El frontend puede ser extendido para otros formularios siguiendo el mismo patrón.
