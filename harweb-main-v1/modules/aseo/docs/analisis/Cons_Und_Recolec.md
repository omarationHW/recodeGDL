# Documentación Técnica: Consulta de Unidades de Recolección

## Descripción General
Este módulo permite consultar y exportar la lista de Unidades de Recolección para un ejercicio fiscal determinado, ordenando por diferentes criterios. Incluye:
- Endpoint API unificado `/api/execute` (patrón eRequest/eResponse)
- Stored Procedure PostgreSQL para consulta eficiente
- Componente Vue.js como página independiente
- Controlador Laravel para orquestación

## Arquitectura
- **Backend**: Laravel + PostgreSQL
- **Frontend**: Vue.js (SPA, página independiente)
- **API**: Único endpoint `/api/execute` que recibe `{ eRequest, params }` y responde `{ success, data, message }`
- **Stored Procedure**: `sp_cons_und_recolec_list` encapsula la lógica de consulta y ordenamiento

## Flujo de Datos
1. El usuario accede a la página de consulta y selecciona el ejercicio y el criterio de orden.
2. Vue.js envía un POST a `/api/execute` con `eRequest: 'cons_und_recolec_list'` y los parámetros.
3. El controlador Laravel ejecuta el stored procedure y retorna los datos.
4. Vue.js muestra la tabla y permite exportar a Excel (CSV).

## Detalles Técnicos
### Endpoint API
- **Ruta**: `/api/execute`
- **Método**: POST
- **Entrada**:
  - `eRequest`: string (ej. 'cons_und_recolec_list')
  - `params`: objeto con parámetros (ejercicio, order)
- **Salida**:
  - `success`: boolean
  - `data`: array de objetos (campos de la tabla)
  - `message`: string (mensaje de error o éxito)

### Stored Procedure
- **Nombre**: `sp_cons_und_recolec_list`
- **Parámetros**:
  - `p_ejercicio` (INTEGER): Ejercicio fiscal
  - `p_order` (TEXT): Campo de ordenamiento
- **Retorna**: Tabla con los campos principales de la unidad de recolección
- **Seguridad**: El campo de ordenamiento se valida usando `format` para evitar SQL Injection

### Vue.js
- Página independiente, sin tabs
- Permite seleccionar ejercicio y orden
- Muestra tabla y exporta a CSV
- Usa axios para llamadas API

### Laravel Controller
- Recibe eRequest y params
- Ejecuta el stored procedure
- Devuelve respuesta estándar

## Seguridad
- El campo de ordenamiento se valida en el stored procedure usando `format` y no se concatena directamente
- El endpoint requiere autenticación (no mostrado aquí, pero debe protegerse en producción)

## Extensibilidad
- Se pueden agregar más operaciones al endpoint `/api/execute` usando nuevos valores de `eRequest`
- El stored procedure puede ampliarse para filtros adicionales

## Ejemplo de Request
```json
{
  "eRequest": "cons_und_recolec_list",
  "params": {
    "ejercicio": 2024,
    "order": "descripcion"
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    {
      "ctrol_recolec": 1,
      "ejercicio_recolec": 2024,
      "cve_recolec": "A",
      "descripcion": "Unidad A",
      "costo_unidad": 100.00,
      "costo_exed": 50.00
    },
    ...
  ],
  "message": ""
}
```
