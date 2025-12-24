# IngresoCaptura

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Ingreso Captura (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite consultar el resumen de pagos capturados por fecha de pago, caja y operación para un mercado y oficina específicos. La migración implementa un endpoint API unificado, un componente Vue.js de página completa y la lógica SQL encapsulada en un stored procedure de PostgreSQL.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getIngresoCaptura",
    "params": {
      "num_mercado": 34,
      "fecha_pago": "2024-06-01",
      "oficina_pago": 2,
      "caja_pago": "A",
      "operacion_pago": 12345
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [
      {
        "fecha_pago": "2024-06-01",
        "caja_pago": "A",
        "operacion_pago": 12345,
        "pagos": 3,
        "importe": 1500.00
      }
    ],
    "message": ""
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_ingreso_captura`
- **Parámetros:**
  - `p_num_mercado` (integer)
  - `p_fecha_pago` (date)
  - `p_oficina_pago` (integer)
  - `p_caja_pago` (varchar)
  - `p_operacion_pago` (integer)
- **Retorna:** Tabla con columnas: fecha_pago, caja_pago, operacion_pago, pagos, importe

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para filtros (mercado, fecha, oficina, caja, operación).
- Tabla de resultados.
- Breadcrumb de navegación.
- Mensajes de error y loading.

## 6. Backend (Laravel)
- Controlador único: `IngresoCapturaController`
- Método `execute` recibe el action y params, despacha al stored procedure correspondiente.
- Validación de parámetros.

## 7. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## 8. Extensibilidad
- El endpoint `/api/execute` puede despachar múltiples acciones (otros formularios) usando el mismo patrón.
- Los stored procedures pueden ampliarse para lógica adicional.

## 9. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con la estructura PostgreSQL.
- El frontend asume que el backend retorna los datos en el formato esperado.

## 10. Ejemplo de Uso
Ver sección de Casos de Uso y Casos de Prueba.


## Casos de Uso

# Casos de Uso - IngresoCaptura

**Categoría:** Form

## Caso de Uso 1: Consulta de Ingreso Capturado para un Mercado y Fecha Específica

**Descripción:** El usuario desea consultar el resumen de pagos capturados para el mercado 34, en la oficina 2, caja 'A', operación 12345, en junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados para esos filtros.

**Pasos a seguir:**
1. Ingresar a la página 'Ingreso Captura'.
2. Ingresar '34' en Número de Mercado.
3. Seleccionar '2024-06-01' como Fecha Pago.
4. Ingresar '2' en Oficina Pago.
5. Ingresar 'A' en Caja Pago.
6. Ingresar '12345' en Operación Pago.
7. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los pagos agrupados por fecha, caja y operación, mostrando el número de periodos y el importe total.

**Datos de prueba:**
{
  "num_mercado": 34,
  "fecha_pago": "2024-06-01",
  "oficina_pago": 2,
  "caja_pago": "A",
  "operacion_pago": 12345
}

---

## Caso de Uso 2: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar sin ingresar el campo 'operacion_pago'.

**Precondiciones:**
El usuario accede al formulario pero omite el campo operación.

**Pasos a seguir:**
1. Ingresar valores en todos los campos excepto 'Operación Pago'.
2. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo es requerido.

**Datos de prueba:**
{
  "num_mercado": 34,
  "fecha_pago": "2024-06-01",
  "oficina_pago": 2,
  "caja_pago": "A"
}

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario consulta un mercado, fecha, oficina, caja y operación para los cuales no existen pagos registrados.

**Precondiciones:**
No existen pagos para los filtros seleccionados.

**Pasos a seguir:**
1. Ingresar filtros que no correspondan a ningún pago registrado.
2. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay resultados.

**Datos de prueba:**
{
  "num_mercado": 99,
  "fecha_pago": "2024-01-01",
  "oficina_pago": 9,
  "caja_pago": "Z",
  "operacion_pago": 99999
}

---



## Casos de Prueba

## Casos de Prueba: Ingreso Captura

### Caso 1: Consulta exitosa
- **Entrada:**
  - num_mercado: 34
  - fecha_pago: 2024-06-01
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 12345
- **Acción:** POST /api/execute con action=getIngresoCaptura
- **Resultado esperado:**
  - success: true
  - data: array con al menos un registro con campos fecha_pago, caja_pago, operacion_pago, pagos, importe

### Caso 2: Parámetro faltante
- **Entrada:**
  - Falta operacion_pago
- **Acción:** POST /api/execute con action=getIngresoCaptura
- **Resultado esperado:**
  - success: false
  - message: 'The operacion_pago field is required.'

### Caso 3: Sin resultados
- **Entrada:**
  - num_mercado: 99
  - fecha_pago: 2024-01-01
  - oficina_pago: 9
  - caja_pago: 'Z'
  - operacion_pago: 99999
- **Acción:** POST /api/execute con action=getIngresoCaptura
- **Resultado esperado:**
  - success: true
  - data: []

### Caso 4: Error de base de datos
- **Simulación:** Forzar error en la base de datos (por ejemplo, cambiar nombre de tabla temporalmente)
- **Resultado esperado:**
  - success: false
  - message: mensaje de error SQL



