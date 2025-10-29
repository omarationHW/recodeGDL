# Documentación Técnica: Migración DifxCobPerito Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar y listar las diferencias por cobrar de transmisiones patrimoniales generadas por peritos externos, agrupando por perito y mostrando el detalle de cada diferencia. La migración se realiza de Delphi a una arquitectura moderna con Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), con un único endpoint `/api/execute` que recibe eRequest/eResponse.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL se encapsula en stored procedures.
- **API:** El endpoint `/api/execute` recibe `{ action, params }` y responde con `{ success, data }`.

## 3. Flujo de Datos
1. El usuario ingresa un rango de fechas y vigencia.
2. El frontend llama a `/api/execute` con `action: 'getPeritos'` y los filtros.
3. El backend ejecuta el SP `sp_difxcobperito_peritos` y retorna la lista de peritos con diferencias.
4. El usuario selecciona un perito y el frontend llama a `/api/execute` con `action: 'getDiferenciasByPerito'`.
5. El backend ejecuta el SP `sp_difxcobperito_diferencias` y retorna el detalle de diferencias.
6. (Opcional) El usuario puede solicitar la impresión de un reporte (dummy endpoint).

## 4. Stored Procedures
- **sp_difxcobperito_peritos:** Devuelve peritos con diferencias en el periodo y vigencia.
- **sp_difxcobperito_diferencias:** Devuelve diferencias detalladas de un perito en el periodo y vigencia.

## 5. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:** `{ action: string, params: object }`
- **Acciones soportadas:**
  - `getPeritos`: Consulta peritos con diferencias
  - `getDiferenciasByPerito`: Consulta diferencias de un perito
  - `printReport`: (dummy) Genera reporte PDF

## 6. Seguridad
- El endpoint puede requerir autenticación JWT o session según la política del sistema.
- Validar los parámetros de entrada en el backend.

## 7. Frontend
- Página Vue.js independiente, sin tabs.
- Formulario de filtros (fechas, vigencia), tabla de peritos, tabla de diferencias.
- Navegación breadcrumb.
- Manejo de errores y loading.

## 8. Consideraciones de Migración
- Los queries Delphi se migran a stored procedures PostgreSQL.
- El frontend no usa componentes tabulares ni tabs, cada formulario es una página.
- El endpoint `/api/execute` es el único punto de entrada para todas las acciones.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

---
