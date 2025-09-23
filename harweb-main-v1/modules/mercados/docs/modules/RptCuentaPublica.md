# Documentación Técnica: Migración RptCuentaPublica (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de reporte "RptCuentaPublica" originalmente en Delphi, migrado a una arquitectura moderna con:
- **Backend:** Laravel (PHP), PostgreSQL (con stored procedures)
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Unificada bajo el patrón eRequest/eResponse en `/api/execute`

## 2. Arquitectura
- **API Unificada:** Todas las operaciones se realizan mediante un único endpoint `/api/execute`.
- **Stored Procedure:** Toda la lógica SQL se encapsula en procedimientos almacenados en PostgreSQL.
- **Frontend:** Cada formulario es una página Vue.js independiente, sin tabs ni componentes tabulares.

## 3. Flujo de Datos
1. El usuario ingresa parámetros (año fiscal, oficina) en la página Vue.
2. Vue envía un POST a `/api/execute` con `eRequest` y `params`.
3. Laravel recibe la petición, identifica el `eRequest`, ejecuta el stored procedure correspondiente y retorna los datos en `eResponse`.
4. Vue muestra el reporte tabular con los datos recibidos.

## 4. Detalles Técnicos
### 4.1. Endpoint API
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Nombre de la operación (ej: `RptCuentaPublica.getReport`)
  - `params`: Parámetros requeridos por la operación
- **Salida:**
  - `eResponse.success`: true/false
  - `eResponse.data`: Datos del reporte (array de objetos)
  - `eResponse.error`: Mensaje de error si aplica

### 4.2. Stored Procedure
- **Nombre:** `rpt_cuenta_publica(axo integer, oficina integer)`
- **Propósito:** Generar el reporte de cuentas por cobrar para el año y oficina seleccionados.
- **Retorna:** Tabla con columnas: recaudadora, descripcion, saldo_mes_anterior, altas_doctos, altas_importe, mov_mes_doctos, mov_mes_importe, bajas_doctos, bajas_importe.
- **Nota:** Adaptar los campos y joins según la estructura real de la base de datos.

### 4.3. Laravel Controller
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método:** `execute(Request $request)`
- **Lógica:**
  - Recibe el eRequest y parámetros.
  - Ejecuta el stored procedure vía DB::select.
  - Retorna la respuesta estructurada.

### 4.4. Vue.js Component
- **Nombre:** `RptCuentaPublica.vue`
- **Características:**
  - Página completa, con breadcrumb.
  - Formulario para parámetros.
  - Tabla de resultados con agrupación de columnas.
  - Mensajes de carga, error y "sin datos".

## 5. Seguridad
- Validar y sanear todos los parámetros recibidos.
- El endpoint debe estar protegido por autenticación (ej: middleware `auth:api` si aplica).

## 6. Consideraciones de Migración
- El reporte Delphi usaba un TQuery sobre `ta_11_categoria`. El SP debe replicar la lógica de negocio y joins necesarios.
- Los nombres de campos pueden requerir ajuste según la estructura real de la base de datos destino.
- El frontend asume que el SP retorna los campos mencionados; ajustar si la estructura difiere.

## 7. Ejemplo de Petición API
```json
{
  "eRequest": "RptCuentaPublica.getReport",
  "params": {
    "axo": 2024,
    "oficina": 1
  }
}
```

## 8. Ejemplo de Respuesta API
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "id": 1,
        "recaudadora": "Oficina Central",
        "descripcion": "Mercado Municipal",
        "saldo_mes_anterior": 10000.00,
        "altas_doctos": 5,
        "altas_importe": 2000.00,
        "mov_mes_doctos": 2,
        "mov_mes_importe": 500.00,
        "bajas_doctos": 1,
        "bajas_importe": 1000.00
      }
    ],
    "error": null
  }
}
```
