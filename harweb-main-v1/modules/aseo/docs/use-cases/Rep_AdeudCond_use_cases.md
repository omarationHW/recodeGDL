# Casos de Uso - Rep_AdeudCond

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa de reporte de adeudos condonados

**Descripción:** El usuario ingresa un número de contrato válido y un tipo de aseo existente, selecciona 'Periodo de Adeudo' y obtiene el reporte correctamente.

**Precondiciones:**
El contrato y tipo de aseo existen y tienen adeudos condonados (status 'S').

**Pasos a seguir:**
1. Ingresar el número de contrato '10001'.
2. Seleccionar tipo de aseo '001 - A - DOMICILIARIO'.
3. Seleccionar 'Periodo de Adeudo' como criterio de ordenamiento.
4. Hacer clic en 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con los adeudos condonados del contrato, ordenados por periodo de pago.

**Datos de prueba:**
{ "num_contrato": 10001, "ctrol_aseo": 1, "opcion": 1 }

---

## Caso de Uso 2: Contrato inexistente

**Descripción:** El usuario ingresa un número de contrato que no existe en la base de datos.

**Precondiciones:**
El número de contrato no existe.

**Pasos a seguir:**
1. Ingresar el número de contrato '99999'.
2. Seleccionar cualquier tipo de aseo.
3. Hacer clic en 'Vista Previa'.

**Resultado esperado:**
Se muestra un mensaje de error: 'No existe el contrato o tipo de aseo seleccionado.'

**Datos de prueba:**
{ "num_contrato": 99999, "ctrol_aseo": 1 }

---

## Caso de Uso 3: Contrato sin adeudos condonados

**Descripción:** El usuario ingresa un contrato válido pero que no tiene adeudos condonados.

**Precondiciones:**
El contrato existe pero no tiene registros en ta_16_pagos con status_vigencia = 'S'.

**Pasos a seguir:**
1. Ingresar el número de contrato '10002'.
2. Seleccionar tipo de aseo '001 - A - DOMICILIARIO'.
3. Hacer clic en 'Vista Previa'.

**Resultado esperado:**
Se muestra un mensaje de error: 'No existen adeudos condonados para este contrato.'

**Datos de prueba:**
{ "num_contrato": 10002, "ctrol_aseo": 1 }

---

