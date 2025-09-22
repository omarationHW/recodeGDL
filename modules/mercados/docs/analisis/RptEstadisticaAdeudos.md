# Documentación Técnica: Migración de RptEstadisticaAdeudos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de estadística global de adeudos vencidos por local y mercado, migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 3+, componente de página independiente, navegación por rutas.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en un stored procedure.

## 3. Flujo de Datos
1. El usuario accede a la página de reporte y selecciona los parámetros (año, periodo, importe mínimo, tipo de reporte).
2. El frontend envía una petición POST a `/api/execute` con `eRequest: 'RptEstadisticaAdeudos'` y los parámetros.
3. El backend recibe la petición, identifica el eRequest y ejecuta el stored procedure correspondiente en PostgreSQL.
4. El resultado se retorna en el campo `data` del eResponse.
5. El frontend muestra la tabla de resultados y totales.

## 4. Detalle de Componentes
### 4.1. Stored Procedure PostgreSQL
- Nombre: `rpt_estadistica_adeudos`
- Parámetros:
  - `p_axo` (año)
  - `p_periodo` (periodo/mes)
  - `p_importe` (importe mínimo, sólo aplica si opc=2)
  - `p_opc` (1=global, 2=filtrado por importe)
- Devuelve: Tabla con columnas `oficina`, `num_mercado`, `local`, `descripcion`, `adeudo`.

### 4.2. Laravel Controller
- Endpoint: `POST /api/execute`
- Entrada: `{ eRequest: 'RptEstadisticaAdeudos', params: {axo, periodo, importe, opc} }`
- Salida: `{ success, message, data }`
- Seguridad: Puede protegerse con middleware de autenticación si se requiere.

### 4.3. Vue.js Component
- Página independiente, no usa tabs.
- Formulario para parámetros.
- Tabla de resultados, totales y mensajes de error.
- Navegación breadcrumb.

## 5. Consideraciones de Seguridad
- Validar que los parámetros sean numéricos y dentro de rangos válidos.
- El endpoint puede requerir autenticación según la política del sistema.

## 6. Manejo de Errores
- Errores de parámetros faltantes o inválidos retornan `success: false` y mensaje descriptivo.
- Errores de base de datos o ejecución retornan mensaje de error en el campo `message`.

## 7. Extensibilidad
- El endpoint `/api/execute` puede manejar otros eRequest para otros formularios/reports.
- El stored procedure puede ser extendido para incluir más filtros si se requiere.

## 8. Pruebas y Validación
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez del módulo.

## 9. Dependencias
- Laravel 10+, PHP 8+
- Vue.js 3+
- PostgreSQL 12+

## 10. Notas de Migración
- El reporte Delphi usaba QuickReport y lógica procedural; ahora toda la lógica SQL está en el stored procedure.
- El frontend es SPA y puede integrarse en cualquier router de Vue.js.
