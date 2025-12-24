# RptPadronEnergia

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - RptPadronEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa del padrón de energía para un mercado existente

**Descripción:** El usuario ingresa una oficina y mercado válidos y obtiene el reporte completo con totales.

**Precondiciones:**
El usuario tiene acceso a la aplicación. Existen registros en las tablas para la oficina y mercado seleccionados.

**Pasos a seguir:**
1. Acceder a la página 'Padrón de Energía Eléctrica'.
2. Ingresar 'Oficina': 1.
3. Ingresar 'Mercado': 2.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con los registros del padrón, el nombre del mercado, el total de registros y el total de cuota mensual.

**Datos de prueba:**
{ "oficina": 1, "mercado": 2 }

---

## Caso de Uso 2: Consulta con parámetros inválidos

**Descripción:** El usuario intenta consultar el reporte sin ingresar los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso a la aplicación.

**Pasos a seguir:**
1. Acceder a la página 'Padrón de Energía Eléctrica'.
2. Dejar vacíos los campos 'Oficina' y 'Mercado'.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros son inválidos.

**Datos de prueba:**
{ "oficina": "", "mercado": "" }

---

## Caso de Uso 3: Consulta de mercado sin registros

**Descripción:** El usuario consulta un mercado/oficina que existe pero no tiene registros de energía.

**Precondiciones:**
El usuario tiene acceso a la aplicación. El mercado/oficina existe pero no hay registros en ta_11_energia para ese mercado.

**Pasos a seguir:**
1. Acceder a la página 'Padrón de Energía Eléctrica'.
2. Ingresar 'Oficina': 99.
3. Ingresar 'Mercado': 99.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla vacía, el nombre del mercado (si existe), y totales en cero.

**Datos de prueba:**
{ "oficina": 99, "mercado": 99 }

---



## Casos de Prueba

# Casos de Prueba: RptPadronEnergia

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta exitosa con datos válidos | oficina=1, mercado=2 | Tabla con registros, totales correctos, nombre de mercado visible |
| 2 | Consulta con oficina no existente | oficina=999, mercado=1 | Tabla vacía, totales en cero, mensaje de éxito pero sin registros |
| 3 | Consulta con mercado no existente | oficina=1, mercado=999 | Tabla vacía, totales en cero, mensaje de éxito pero sin registros |
| 4 | Consulta con ambos parámetros vacíos | oficina=, mercado= | Mensaje de error de validación en frontend y backend |
| 5 | Consulta con parámetros no numéricos | oficina='abc', mercado='xyz' | Mensaje de error de validación en backend |
| 6 | Consulta con mercado/oficina sin registros de energía | oficina=99, mercado=99 | Tabla vacía, totales en cero, nombre de mercado si existe |
| 7 | Consulta con valores límite (oficina=0, mercado=0) | oficina=0, mercado=0 | Mensaje de error de validación |
| 8 | Consulta con SQL injection en parámetros | oficina="1;DROP TABLE ta_11_energia;--", mercado=2 | Mensaje de error de validación, sin ejecución de SQL malicioso |



