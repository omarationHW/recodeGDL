# Documentación: ListAna

## Análisis Técnico

# Documentación Técnica: Migración Formulario ListAna (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "Listado Analítico del Ingreso Diario" (ListAna) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo seleccionar fecha, recaudadora y caja, y generar un reporte analítico de ingresos diarios.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getCajasByFechaRecaud", // o getTotImp, getMinFolio, getMaxFolio, getPagosDetalle
      "params": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
Toda la lógica de consulta se implementa como funciones en PostgreSQL:
- `sp_get_cajas_by_fecha_recaud(fecha, recaud)`
- `sp_get_tot_imp(fecha, caja, recaud)`
- `sp_get_min_folio(fecha, caja, recaud)`
- `sp_get_max_folio(fecha, caja, recaud)`
- `sp_get_pagos_detalle(fecha, caja, recaud)`

## 5. Flujo de la Página Vue.js
1. Al cargar la página, se selecciona la fecha actual y la primera recaudadora.
2. Al cambiar fecha o recaudadora, se consulta la lista de cajas disponibles.
3. Al seleccionar "Imprimir", se consultan los totales, folios y detalle de pagos.
4. El reporte se muestra en pantalla (no imprime físicamente, pero puede exportarse o imprimirse desde el navegador).

## 6. Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint `/api/execute` puede protegerse con middleware de autenticación según la política del sistema.

## 7. Consideraciones de Migración
- Los combos de recaudadora y caja se mantienen como en Delphi.
- El reporte se muestra en tabla HTML, no como reporte impreso.
- El frontend es completamente independiente y funcional por sí solo.

## 8. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 9. Dependencias
- Laravel 9+
- Vue.js 2/3 (compatible)
- PostgreSQL 12+

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba para ejemplos y validaciones.

## Casos de Uso

# Casos de Uso - ListAna

**Categoría:** Form

## Caso de Uso 1: Consulta de cajas disponibles para una fecha y recaudadora

**Descripción:** El usuario selecciona una fecha y una recaudadora, y el sistema muestra las cajas disponibles para esa combinación.

**Precondiciones:**
Existen registros en la tabla pagos para la fecha y recaudadora seleccionadas.

**Pasos a seguir:**
1. El usuario ingresa a la página ListAna.
2. Selecciona una fecha y una recaudadora.
3. El sistema consulta las cajas disponibles y las muestra en el combo de cajas.

**Resultado esperado:**
El combo de cajas se llena con las cajas disponibles para la fecha y recaudadora seleccionadas.

**Datos de prueba:**
fecha: '2024-06-10', recaud: '1'

---

## Caso de Uso 2: Generación de reporte analítico de ingresos diarios

**Descripción:** El usuario selecciona fecha, recaudadora y caja, y genera el reporte con totales y detalle.

**Precondiciones:**
Existen pagos registrados para la fecha, recaudadora y caja seleccionadas.

**Pasos a seguir:**
1. El usuario selecciona fecha, recaudadora y caja.
2. Da clic en 'Imprimir'.
3. El sistema consulta totales, folios y detalle de pagos y muestra el reporte.

**Resultado esperado:**
Se muestra el resumen de totales, folios y el detalle de pagos en la tabla.

**Datos de prueba:**
fecha: '2024-06-10', recaud: '1', caja: 'A'

---

## Caso de Uso 3: Manejo de ausencia de datos

**Descripción:** El usuario selecciona una combinación de fecha, recaudadora y caja para la cual no existen pagos.

**Precondiciones:**
No existen registros en pagos para la combinación seleccionada.

**Pasos a seguir:**
1. El usuario selecciona fecha, recaudadora y caja sin datos.
2. Da clic en 'Imprimir'.
3. El sistema muestra totales y folios en cero o vacío, y la tabla de detalle vacía.

**Resultado esperado:**
El sistema indica que no hay datos para mostrar, sin errores.

**Datos de prueba:**
fecha: '2024-01-01', recaud: '5', caja: 'Z'

---

## Casos de Prueba

# Casos de Prueba ListAna

| # | Descripción | Datos de Entrada | Resultado Esperado |
|---|-------------|------------------|-------------------|
| 1 | Consulta de cajas para fecha y recaudadora válidas | fecha: '2024-06-10', recaud: '1' | Lista de cajas no vacía |
| 2 | Consulta de cajas para fecha y recaudadora sin datos | fecha: '2024-01-01', recaud: '5' | Lista de cajas vacía |
| 3 | Generación de reporte con datos | fecha: '2024-06-10', recaud: '1', caja: 'A' | Totales, folios y detalle mostrados correctamente |
| 4 | Generación de reporte sin datos | fecha: '2024-01-01', recaud: '5', caja: 'Z' | Totales y folios en cero/vacío, tabla detalle vacía |
| 5 | Cambio de recaudadora actualiza cajas | Cambiar recaud de '1' a '2' | Combo de cajas se actualiza |
| 6 | Error de conexión a API | Desconectar backend | Mensaje de error visible en frontend |
| 7 | Validación de campos requeridos | No seleccionar fecha o recaud | Botón 'Imprimir' deshabilitado o error de validación |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

