# Casos de Uso - propuestatab1

**Categoría:** Form

## Caso de Uso 1: Consulta de Cuenta Histórica

**Descripción:** El usuario consulta los datos históricos de una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario ingresa la clave de cuenta en el campo de búsqueda.
2. El usuario presiona 'Buscar'.
3. El sistema envía un eRequest con action 'show' y el parámetro cvecuenta.
4. El backend ejecuta el stored procedure propuestatab1_show.
5. El frontend muestra los datos generales de la cuenta.

**Resultado esperado:**
Se muestran los datos históricos de la cuenta solicitada.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

## Caso de Uso 2: Visualización de Régimen de Propiedad

**Descripción:** El usuario navega a la página de régimen de propiedad de una cuenta.

**Precondiciones:**
El usuario ya consultó una cuenta válida.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Régimen de Propiedad'.
2. El sistema envía un eRequest con action 'regimen' y el parámetro cvecuenta.
3. El backend ejecuta el stored procedure propuestatab1_regimen.
4. El frontend muestra la tabla de régimen de propiedad.

**Resultado esperado:**
Se muestra la información de régimen de propiedad de la cuenta.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

## Caso de Uso 3: Consulta de Pagos de Transmisión Patrimonial

**Descripción:** El usuario consulta los pagos de transmisiones patrimoniales de una cuenta.

**Precondiciones:**
El usuario ya consultó una cuenta válida.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Pagos'.
2. El sistema envía un eRequest con action 'pagos' y el parámetro cvecuenta.
3. El backend ejecuta el stored procedure propuestatab1_pagos.
4. El frontend muestra la tabla de pagos.

**Resultado esperado:**
Se muestran los pagos de transmisiones patrimoniales de la cuenta.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

