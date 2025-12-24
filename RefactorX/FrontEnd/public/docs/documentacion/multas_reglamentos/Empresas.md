# Documentación: Empresas

## Análisis Técnico

# Documentación Técnica - Migración Formulario Empresas (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (Vite/SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (Stored Procedures para lógica de negocio)
- **Patrón API:** eRequest/eResponse (todas las operaciones por un solo endpoint)

## Flujo General
1. **Frontend** envía un objeto `eRequest` a `/api/execute` con la acción y parámetros.
2. **Laravel Controller** recibe el request, despacha la acción y llama al stored procedure correspondiente.
3. **Stored Procedures** ejecutan la lógica y devuelven los datos requeridos.
4. **Laravel** retorna un objeto `eResponse` con `success`, `data`, y `message`.
5. **Frontend** procesa la respuesta y actualiza la UI.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: '...', ...params } }`
  - Salida: `{ eResponse: { success: bool, data: ..., message: string } }`

## Acciones soportadas
- `get_ejecutores`: Catálogo de ejecutores
- `check_cuenta`: Verifica existencia de cuenta para ejecutor y fecha
- `check_empresa_diferente`: Verifica si la cuenta existe para otro ejecutor
- `insert_ctaempexterna`: Inserta cuenta en ctaempexterna
- `get_empresas_folios`: Consulta/actualiza folios
- `get_predial_principal`: Reporte principal predial
- `get_predial_detalle`: Detalle predial
- ... (agregar más según necesidades)

## Frontend (Vue.js)
- **EmpresasAsignarCuentas.vue**: Página para subir archivo, procesar y asignar cuentas
- **EmpresasAsignarFolios.vue**: Página para buscar y practicar folios
- **EmpresasGenerarExcel.vue**: Página para consultar y exportar información a Excel
- **Navegación:** Cada página es independiente, sin tabs. Se recomienda usar rutas `/empresas/asignar-cuentas`, `/empresas/asignar-folios`, `/empresas/generar-excel`.

## Backend (Laravel)
- **EmpresasController**: Un solo método `execute` que despacha según `eRequest['action']`.
- **Validación:** Se recomienda validar los parámetros antes de llamar al SP.
- **Errores:** Todos los errores se devuelven en `eResponse['message']`.

## Base de Datos (PostgreSQL)
- **Stored Procedures**: Toda la lógica de negocio y reportes se implementa en SPs.
- **Tipos compuestos:** Para reportes complejos, definir tipos compuestos o vistas.
- **Transacciones:** Usar transacciones en SPs que modifiquen datos.

## Seguridad
- **Autenticación:** Se recomienda JWT o Sanctum para proteger el endpoint.
- **Validación:** Validar tipos y rangos en el backend y SPs.

## Exportación a Excel
- **Frontend:** Se usa SheetJS (XLSX) para exportar los datos a Excel en el navegador.
- **Backend:** Opcionalmente, se puede implementar exportación en el backend si se requiere.

## Consideraciones
- **Carga de archivos:** El archivo de cuentas se procesa en el frontend y se hacen llamadas por cada línea/cuenta (optimizable por lote si es necesario).
- **Escalabilidad:** El endpoint único permite agregar nuevas acciones fácilmente.
- **Mantenibilidad:** Toda la lógica de negocio está centralizada en SPs y el controlador Laravel.

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

