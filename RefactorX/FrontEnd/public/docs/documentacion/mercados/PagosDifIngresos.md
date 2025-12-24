# PagosDifIngresos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Inconsistencias de Pagos (PagosDifIngresos)

## Descripción General
Este módulo permite consultar y exportar inconsistencias en los pagos registrados en el sistema de mercados municipales, específicamente:

- **Pagos con renta errónea**: Pagos cuyo importe no coincide con la renta esperada según la configuración del local.
- **Pagos con datos diferentes en ingresos**: Pagos donde la cuenta, caja o número de operación no corresponde con la configuración del mercado.

## Arquitectura
- **Backend**: Laravel (PHP) + PostgreSQL
- **Frontend**: Vue.js (SPA, página independiente)
- **API**: Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de Datos**: PostgreSQL, lógica principal en stored procedures

## Flujo de Datos
1. El usuario accede a la página de inconsistencias de pagos.
2. Selecciona la recaudadora y el rango de fechas.
3. Selecciona el tipo de inconsistencia a consultar (renta errónea o datos erróneos).
4. El frontend envía la petición a `/api/execute` con el action correspondiente.
5. El backend ejecuta el stored procedure adecuado y retorna los resultados.
6. El usuario puede exportar los resultados a Excel (CSV).

## API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getPagosRentaErronea", // o "getPagosDiferentes"
      "params": {
        "rec": 1,
        "fpadsd": "2024-01-01",
        "fpahst": "2024-01-31"
      }
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

## Stored Procedures
- **spd_11_dif_pagos**: Devuelve pagos con datos diferentes en ingresos.
- **spd_11_dif_renta**: Devuelve pagos con renta errónea.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, si aplica).
- Los parámetros son validados en backend.

## Exportación
- El frontend genera el archivo CSV a partir de los datos recibidos.

## Consideraciones
- El frontend es una página independiente, sin tabs.
- El backend es desacoplado y solo expone el endpoint unificado.
- Los stored procedures pueden ser reutilizados por otros módulos.

# Estructura de la Página Vue
- Formulario de selección de recaudadora y fechas.
- Selección de tipo de inconsistencia.
- Tabla de resultados dinámica.
- Botón de exportar a Excel (CSV).

# Casos de Uso
Ver sección `use_cases`.

# Casos de Prueba
Ver sección `test_cases`.


## Casos de Uso

# Casos de Uso - PagosDifIngresos

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos con renta errónea

**Descripción:** El usuario desea obtener todos los pagos realizados en la recaudadora 1 entre el 1 y el 31 de enero de 2024, donde el importe pagado no coincide con la renta esperada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en ese rango de fechas.

**Pasos a seguir:**
1. Acceder a la página de Inconsistencias de Pagos.
2. Seleccionar la recaudadora 'Zona Centro'.
3. Ingresar fecha desde '2024-01-01' y fecha hasta '2024-01-31'.
4. Seleccionar el tipo 'Renta Errónea'.
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los pagos que tienen importe diferente a la renta esperada para cada local.

**Datos de prueba:**
Pagos en ta_11_pagos_local con importe_pago diferente al calculado según la renta del local.

---

## Caso de Uso 2: Exportar pagos con datos diferentes en ingresos

**Descripción:** El usuario desea exportar a Excel todos los pagos con cuenta/caja/operación errónea en la recaudadora 2 durante febrero de 2024.

**Precondiciones:**
El usuario tiene acceso y existen pagos con datos erróneos en ese periodo.

**Pasos a seguir:**
1. Acceder a la página de Inconsistencias de Pagos.
2. Seleccionar la recaudadora 'Zona Olímpica'.
3. Ingresar fecha desde '2024-02-01' y fecha hasta '2024-02-29'.
4. Seleccionar el tipo 'Datos de Pagos y/o cuenta Erróneos'.
5. Hacer clic en 'Buscar'.
6. Hacer clic en 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo CSV con los pagos que tienen cuenta, caja o número de operación diferente al esperado.

**Datos de prueba:**
Pagos en ta_11_pagos_local con cuenta/caja/operación no coincidente con la configuración del mercado.

---

## Caso de Uso 3: Validación de parámetros obligatorios

**Descripción:** El usuario intenta buscar inconsistencias sin seleccionar recaudadora o fechas.

**Precondiciones:**
El usuario accede a la página pero no llena todos los campos.

**Pasos a seguir:**
1. Acceder a la página de Inconsistencias de Pagos.
2. Dejar vacío el campo de recaudadora o fechas.
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los campos son obligatorios y no realiza la consulta.

**Datos de prueba:**
Campos vacíos en el formulario.

---



## Casos de Prueba

# Casos de Prueba: Inconsistencias de Pagos

## Caso 1: Consulta de pagos con renta errónea
- **Entrada**: rec=1, fpadsd=2024-01-01, fpahst=2024-01-31, tipo='renta'
- **Acción**: POST /api/execute con action 'getPagosRentaErronea'
- **Resultado esperado**: Lista de pagos con importe_pago <> renta esperada

## Caso 2: Consulta de pagos con datos diferentes en ingresos
- **Entrada**: rec=2, fpadsd=2024-02-01, fpahst=2024-02-29, tipo='datos'
- **Acción**: POST /api/execute con action 'getPagosDiferentes'
- **Resultado esperado**: Lista de pagos con cuenta/caja/operación errónea

## Caso 3: Exportar resultados a Excel
- **Entrada**: rec=1, fpadsd=2024-01-01, fpahst=2024-01-31, tipo='renta'
- **Acción**: POST /api/execute con action 'exportPagosRentaErronea'
- **Resultado esperado**: Descarga de archivo CSV con los resultados

## Caso 4: Validación de campos obligatorios
- **Entrada**: rec='', fpadsd='', fpahst='', tipo='renta'
- **Acción**: POST /api/execute con action 'getPagosRentaErronea'
- **Resultado esperado**: Error de validación, mensaje de campos obligatorios

## Caso 5: Sin resultados
- **Entrada**: rec=99, fpadsd=2024-01-01, fpahst=2024-01-31, tipo='datos'
- **Acción**: POST /api/execute con action 'getPagosDiferentes'
- **Resultado esperado**: Lista vacía, mensaje 'No se encontraron resultados.'



