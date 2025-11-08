# Documentación Técnica: Migración RptPadronEnergia (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el reporte "Padrón de Energía Eléctrica del Mercado" originalmente desarrollado en Delphi, migrado a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+, endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3+, componente de página independiente
- **Base de Datos:** PostgreSQL, lógica de reporte en stored procedure

## 3. Flujo de Datos
1. El usuario accede a la página del reporte y selecciona los parámetros (oficina, mercado).
2. El frontend envía una petición POST a `/api/execute` con el action `RptPadronEnergia.getReport` y los parámetros.
3. El backend valida los parámetros y ejecuta el stored procedure `rpt_padron_energia`.
4. El resultado se retorna en el formato eResponse, incluyendo los totales y la descripción del mercado.
5. El frontend muestra la tabla de resultados y los totales.

## 4. Detalle de Componentes
### 4.1. Stored Procedure: `rpt_padron_energia`
- Recibe: `p_oficina` (integer), `p_mercado` (integer)
- Devuelve: Todos los campos requeridos para el reporte, incluyendo el campo calculado `datoslocal` (concatenación de varios campos según la lógica Delphi).
- Ordena los resultados según la lógica original.

### 4.2. Laravel Controller: `ExecuteController`
- Endpoint: `/api/execute`
- Recibe: JSON con `eRequest.action` y `eRequest.data`
- Acción relevante: `RptPadronEnergia.getReport`
- Valida parámetros, ejecuta el SP, calcula totales, retorna datos y totales en `eResponse`.

### 4.3. Vue.js Component: `RptPadronEnergiaPage`
- Página independiente (no tab)
- Formulario para parámetros
- Tabla de resultados con totales
- Manejo de loading, error, y formato de moneda
- Navegación breadcrumb

## 5. Esquema de Tablas (Referencia)
- **ta_11_mercados**: contiene mercados, campo clave `oficina`, `num_mercado_nvo`, `descripcion`
- **ta_11_locales**: contiene locales, campos clave `id_local`, `oficina`, `num_mercado`, etc.
- **ta_11_energia**: contiene datos de energía, campo clave `id_local`, `cantidad`, `vigencia`, etc.

## 6. API: Formato eRequest/eResponse
- **Request:**
```json
{
  "eRequest": {
    "action": "RptPadronEnergia.getReport",
    "data": {
      "oficina": 1,
      "mercado": 2
    }
  }
}
```
- **Response (éxito):**
```json
{
  "eResponse": {
    "success": true,
    "message": "Reporte generado correctamente",
    "data": {
      "descripcion_mercado": "Mercado Central",
      "registros": [ ... ],
      "total_registros": 10,
      "total_cuota": 12345.67
    }
  }
}
```
- **Response (error):**
```json
{
  "eResponse": {
    "success": false,
    "message": "Parámetros inválidos",
    "errors": { ... }
  }
}
```

## 7. Seguridad
- Validación estricta de parámetros en backend
- No se exponen detalles internos de la base de datos
- El SP sólo permite lectura

## 8. Consideraciones
- El campo `datoslocal` se calcula en el SP para mantener la lógica original Delphi
- El frontend es desacoplado y puede integrarse en cualquier SPA
- El endpoint es extensible para otras acciones
