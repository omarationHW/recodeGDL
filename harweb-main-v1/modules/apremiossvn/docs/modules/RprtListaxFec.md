# Documentación Técnica: Migración Formulario RprtListaxFec (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte "RprtListaxFec" de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la lógica de negocio y presentación, pero modernizando la tecnología y facilitando la integración y el mantenimiento.

## 2. Arquitectura
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3+ (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (Stored Procedures para lógica de reportes)

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "rprt_listaxfec",
    "params": {
      "vrec": 1,
      "vmod": 11,
      "vcve": 1,
      "vfec1": "2024-01-01",
      "vfec2": "2024-01-31",
      "vvig": "todas",
      "veje": "todos"
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedure (PostgreSQL)
- **Nombre:** `rprt_listaxfec`
- **Tipo:** REPORT
- **Descripción:** Genera el listado de requerimientos por fecha y módulo, aplicando los filtros y joins necesarios según la lógica original Delphi.
- **Parámetros:**
  - `vrec` (int): Zona/Recaudadora
  - `vmod` (int): Módulo (11=Mercados, 16=Aseo, etc.)
  - `vcve` (int): Tipo de fecha a filtrar
  - `vfec1`, `vfec2` (date): Rango de fechas
  - `vvig` (string): Vigencia ('todas', '1', '2', 'P')
  - `veje` (string): Ejecutor ('todos', 'ninguno', o id)
- **Retorna:** Tabla con todos los campos requeridos para el reporte.

## 5. Lógica de Negocio Migrada
- **Filtros dinámicos:**
  - Por zona, módulo, vigencia, ejecutor y tipo de fecha.
- **Joins:**
  - Se mantienen los joins con ejecutores, recaudadoras y zonas.
- **Ordenamiento:**
  - Según el tipo de fecha seleccionado (`vcve`).
- **Campos calculados:**
  - El campo `datos` puede ser enriquecido en el frontend o mediante otro SP si se requiere lógica adicional por módulo.

## 6. Frontend (Vue.js)
- **Página independiente:**
  - Cada formulario es una página con su propia ruta.
- **Formulario de filtros:**
  - Inputs para todos los parámetros requeridos.
- **Tabla de resultados:**
  - Muestra todos los campos relevantes del reporte.
- **Manejo de estados:**
  - Loading, error, y visualización de resultados.

## 7. Seguridad
- **Validación de parámetros** en el backend.
- **Protección de endpoint** mediante autenticación (no incluida aquí, pero recomendada).

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar más reportes y procesos usando el patrón `eRequest`.
- Los stored procedures pueden ser extendidos para lógica adicional o cálculos complejos.

## 9. Consideraciones
- El campo `datos` puede requerir lógica adicional por módulo (como en el método `QryFolioCalcFields` de Delphi). Se recomienda implementar SPs adicionales o lógica en el backend si se requiere el mismo comportamiento.
- El frontend puede ser adaptado para exportar a PDF/Excel si se requiere.

## 10. Ejemplo de llamada desde Frontend
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    eRequest: 'rprt_listaxfec',
    params: {
      vrec: 1,
      vmod: 11,
      vcve: 1,
      vfec1: '2024-01-01',
      vfec2: '2024-01-31',
      vvig: 'todas',
      veje: 'todos'
    }
  })
})
.then(res => res.json())
.then(data => console.log(data));
```
