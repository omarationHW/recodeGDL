# Documentación Técnica: Migración Formulario Prepago (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las operaciones pasan por `/api/execute`.

## 2. Flujo de Datos
1. El usuario ingresa la cuenta catastral y solicita información.
2. El frontend llama `/api/execute` con `{ eRequest: { action: 'getPrepagoData', params: { cvecuenta } } }`.
3. El backend ejecuta el SP `sp_prepago_get_data` y retorna los datos del contribuyente.
4. Para el detalle de adeudo, se llama `sp_prepago_liquidacion_parcial`.
5. Para descuentos, se llama `sp_prepago_get_descuentos`.
6. Para último requerimiento, se llama `sp_prepago_get_ultimo_requerimiento`.
7. Para acciones de proceso (recalcular/eliminar DPP, calcular descuento), se llaman los SP correspondientes.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: '...', params: { ... } } }`
- **Salida**: `{ eResponse: { ... } }`

## 4. Seguridad
- Autenticación JWT recomendada (no incluida en ejemplo).
- Validación de parámetros en el controlador.
- Todas las operaciones de escritura pasan por stored procedures.

## 5. Stored Procedures
- Toda la lógica de negocio y reglas de cálculo se implementa en SPs.
- Los SPs devuelven datos en formato tabla o JSON según el caso.
- Los SPs de proceso retornan 'OK' o mensaje de error.

## 6. Frontend
- El componente Vue es una página completa, sin tabs.
- Navegación por rutas (ejemplo: `/prepago`).
- Cada acción del usuario llama a `/api/execute` con el action adecuado.
- Manejo de estados: loading, error, datos.
- Liquidación parcial abre un modal para ingresar año/bimestre.
- Descuentos y último requerimiento se muestran en secciones independientes.

## 7. Consideraciones de Migración
- Los nombres de SP y parámetros siguen el estándar snake_case.
- Los cálculos de totales y sumatorias se hacen en el backend.
- El frontend sólo muestra datos y envía acciones.
- El endpoint es extensible para otros formularios.

## 8. Pruebas y Validación
- Casos de uso y pruebas incluidas para validar la funcionalidad principal.
- Se recomienda pruebas de integración y unitarias para cada SP y endpoint.

## 9. Extensibilidad
- Para agregar nuevos formularios, crear nuevos SP y métodos en el controlador.
- El frontend puede agregar nuevas páginas siguiendo el mismo patrón.

---
