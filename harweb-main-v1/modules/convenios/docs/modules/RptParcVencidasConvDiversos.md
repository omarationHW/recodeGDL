# Documentación Técnica: Parcialidades Vencidas Convenios Diversos

## Descripción General
Este módulo permite consultar y exportar el reporte de parcialidades vencidas de convenios diversos, agrupando por convenio y mostrando pagos al corriente, vencidos y adeudos. Incluye:
- Endpoint API unificado `/api/execute` (Laravel)
- Componente Vue.js de página completa
- Stored Procedure PostgreSQL para el reporte
- Exportación a Excel

## Arquitectura
- **Backend:** Laravel Controller (API REST, endpoint único)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (stored procedure)
- **API Pattern:** eRequest/eResponse (action, params)

## Flujo de Datos
1. El usuario accede a la página de reporte y llena los filtros (tipo, subtipo, fecha, zona, estado).
2. Al enviar el formulario, Vue.js realiza un POST a `/api/execute` con action `getReport` y los parámetros.
3. El controlador Laravel ejecuta el stored procedure `sp_parcialidades_vencidas_conv_diversos` con los parámetros recibidos.
4. El resultado se devuelve en formato JSON y se muestra en la tabla.
5. El usuario puede exportar a Excel usando el botón correspondiente (simulado en este ejemplo).

## Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "getReport",
    "params": {
      "tipo": 1,
      "subtipo": 2,
      "fechahst": "2024-06-30",
      "letras": "ZC1",
      "est": "A"
    }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success",
    "data": [ ... ],
    "message": "Reporte generado correctamente"
  }
  ```

## Stored Procedure
- **Nombre:** `sp_parcialidades_vencidas_conv_diversos`
- **Parámetros:** tipo, subtipo, fechahst, letras, est
- **Retorna:** Tabla con columnas de convenio, nombre, pagos, recargos, adeudos, etc.

## Frontend (Vue.js)
- Página independiente, sin tabs
- Formulario de filtros
- Tabla de resultados
- Botón de exportar Excel
- Breadcrumb de navegación

## Seguridad
- Validación de parámetros en backend
- Manejo de errores y mensajes claros

## Consideraciones
- El endpoint es unificado para todas las acciones (getReport, exportExcel, etc.)
- El SP puede ser extendido para filtros adicionales si se requiere
- El frontend puede ser adaptado a cualquier framework SPA compatible

# Estructura de la Base de Datos
- `ta_17_conv_diverso`, `ta_17_conv_d_resto`, `ta_17_conv_pagos`, `ta_17_adeudos_div`, `ta_17_subtipo_conv`, `ta_17_tipos`

# Integración
- El SP debe estar creado en la base de datos PostgreSQL
- El endpoint `/api/execute` debe estar registrado en Laravel routes/api.php
- El componente Vue debe estar registrado en el router como página independiente

# Pruebas y Validación
- Se recomienda probar con diferentes combinaciones de filtros
- Validar que los totales y agrupaciones coincidan con los reportes originales de Delphi

# Mantenimiento
- El SP puede ser modificado para agregar más columnas o filtros
- El controlador puede ser extendido para nuevas acciones (CRUD, etc.)
