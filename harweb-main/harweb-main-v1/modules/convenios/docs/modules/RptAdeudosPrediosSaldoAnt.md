# Documentación Técnica: Migración RptAdeudosPrediosSaldoAnt (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde al formulario de reporte de adeudos de predios con saldo anterior, originalmente implementado en Delphi. La migración se realiza a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), siguiendo un patrón de API unificada y desacoplada.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** Entrada y salida bajo el esquema `eRequest`/`eResponse`.

## 3. Flujo de Datos
1. El usuario accede a la página de reporte y selecciona los filtros (subtipo, fechas, estado).
2. El frontend envía un POST a `/api/execute` con `eRequest` indicando la acción (`getReport`) y los parámetros.
3. El backend valida los parámetros y ejecuta el stored procedure correspondiente en PostgreSQL.
4. El resultado se retorna en `eResponse.data` y se muestra en la tabla del frontend.

## 4. Endpoints y Acciones
- **/api/execute** (POST)
  - `action: getReport` → Ejecuta el reporte principal.
  - `action: getSubtipos` → Devuelve catálogo de subtipos.
  - `action: getSaldoAnterior` → Devuelve saldo anterior de un predio.

## 5. Stored Procedures
- **sp_rpt_adeudos_predios_saldo_ant**: Genera el reporte principal, agrupando por manzana/lote y calculando saldo anterior.
- **sp_get_saldo_anterior_predio**: Calcula el saldo anterior de un predio antes de una fecha.

## 6. Validaciones
- Todos los parámetros son validados en el backend antes de ejecutar el SP.
- El frontend valida campos requeridos y tipos de datos.

## 7. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política de la aplicación.
- Los SP sólo retornan datos permitidos, sin exponer información sensible.

## 8. Consideraciones de Migración
- Los cálculos de campos como `letracomp` y `saldoanterior` se realizan en el SP para eficiencia.
- El frontend es una página independiente, no usa tabs ni componentes tabulares.
- El API es desacoplado y puede ser consumido por otros clientes.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y la migración correcta.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SP pueden ser extendidos para nuevos reportes o filtros.

---
