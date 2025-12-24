# RptCuentaPublica

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - RptCuentaPublica

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte para oficina central en año actual

**Descripción:** El usuario desea obtener el reporte de cuentas por cobrar para la oficina central en el año fiscal actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos para la oficina central en el año actual.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Cuenta Pública.
2. Seleccionar el año fiscal actual (ej: 2024).
3. Ingresar el número de oficina correspondiente a la oficina central (ej: 1).
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra el reporte tabular con los conceptos, saldos, altas, movimientos y bajas correspondientes a la oficina central para el año seleccionado.

**Datos de prueba:**
{ "axo": 2024, "oficina": 1 }

---

## Caso de Uso 2: Consulta de reporte para oficina inexistente

**Descripción:** El usuario intenta consultar el reporte para una oficina que no existe o no tiene datos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Cuenta Pública.
2. Seleccionar un año fiscal válido (ej: 2024).
3. Ingresar un número de oficina inexistente (ej: 9999).
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron datos para los parámetros seleccionados.

**Datos de prueba:**
{ "axo": 2024, "oficina": 9999 }

---

## Caso de Uso 3: Error por parámetros faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar a la página de Reporte Cuenta Pública.
2. Dejar vacío el campo de año fiscal o de oficina.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{ "axo": null, "oficina": 1 }

---



## Casos de Prueba

# Casos de Prueba: RptCuentaPublica

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta exitosa con datos existentes | axo=2024, oficina=1 | Respuesta con success=true y data con al menos un registro |
| 2 | Consulta con oficina sin datos | axo=2024, oficina=9999 | Respuesta con success=true y data vacía ([]) |
| 3 | Parámetro axo faltante | axo=null, oficina=1 | Respuesta con success=false y error indicando parámetro requerido |
| 4 | Parámetro oficina faltante | axo=2024, oficina=null | Respuesta con success=false y error indicando parámetro requerido |
| 5 | Parámetros inválidos (texto en vez de número) | axo='abcd', oficina='xyz' | Respuesta con success=false y error de validación |
| 6 | SQL error en SP (simulado) | axo=2024, oficina=1 (con SP alterado para lanzar error) | Respuesta con success=false y mensaje de error SQL |
| 7 | Consulta con año futuro sin datos | axo=2099, oficina=1 | Respuesta con success=true y data vacía ([]) |



