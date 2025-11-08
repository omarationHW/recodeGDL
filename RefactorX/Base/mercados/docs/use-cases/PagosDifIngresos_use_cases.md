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

