# Documentación Técnica: Migración de Formulario RptReq_pba (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un `eRequest` y parámetros, y responde con un `eResponse`.
- **Frontend**: Componente Vue.js como página independiente, que consume la API y muestra el reporte.
- **Base de Datos**: PostgreSQL con stored procedures para encapsular la lógica de negocio y reportes.

## 2. Endpoint Unificado

- **Ruta**: `/api/execute`
- **Método**: POST
- **Entrada**:
  - `eRequest`: Identificador de la acción (ej: `RptReqPba_getReportData`)
  - `params`: Objeto con los parámetros requeridos por el stored procedure
- **Salida**:
  - `success`: true/false
  - `data`: Resultado de la consulta
  - `message`: Mensaje de error o información

## 3. Stored Procedures

- Toda la lógica SQL y de cálculo (recargos, gastos, filtros) se implementa en funciones de PostgreSQL.
- Los procedimientos devuelven tablas o valores calculados según la lógica original Delphi.
- El cálculo de recargos se encapsula en una función reutilizable.

## 4. Controlador Laravel

- Recibe el `eRequest` y parámetros.
- Ejecuta el stored procedure correspondiente usando DB::select.
- Devuelve el resultado en formato JSON estándar.
- Maneja errores y validaciones básicas.

## 5. Componente Vue.js

- Página independiente, sin tabs.
- Formulario para parámetros de consulta (mercado, local, sección).
- Tabla de resultados con todos los campos relevantes.
- Botón para exportar a PDF (placeholder, requiere implementación).
- Manejo de loading y errores.
- Filtros para formato de moneda.

## 6. Seguridad

- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar y sanear los parámetros recibidos en el backend.

## 7. Extensibilidad

- Para agregar nuevos reportes o acciones, basta con crear un nuevo stored procedure y mapearlo en el controlador.
- El frontend puede adaptarse fácilmente a nuevos parámetros o columnas.

## 8. Consideraciones de Migración

- Los nombres de tablas y campos deben coincidir con la estructura original.
- Los cálculos de recargos y gastos replican la lógica Delphi.
- El reporte puede ser extendido para impresión/exportación según necesidades.

## 9. Ejemplo de Llamada API

```json
{
  "eRequest": "RptReqPba_getReportData",
  "params": {
    "vmerc1": 1,
    "vmerc2": 2,
    "vlocal1": 1,
    "vlocal2": 100,
    "vsecc": "todas"
  }
}
```

## 10. Flujo de Datos

1. Usuario ingresa parámetros en la página Vue.
2. Vue envía POST a `/api/execute` con eRequest y params.
3. Laravel ejecuta el stored procedure correspondiente.
4. El resultado se muestra en la tabla de la página.

---
