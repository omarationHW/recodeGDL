# Casos de Uso - areatitulofrm

**Categoría:** Form

## Caso de Uso 1: Actualizar área según título para cuenta con subpredio

**Descripción:** El usuario actualiza el área según título de una cuenta catastral que corresponde a un subpredio (condominio).

**Precondiciones:**
La cuenta existe y tiene subpredio > 0.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta catastral.
2. El sistema muestra los datos actuales.
3. El usuario ingresa un nuevo valor para área según título y una observación.
4. El usuario presiona 'Actualizar'.
5. El sistema actualiza el registro sin validar diferencia porcentual.

**Resultado esperado:**
El área según título se actualiza correctamente y se registra la observación.

**Datos de prueba:**
{ "cvecuenta": 12345, "areatitulo": 85.5, "observacion": "Actualización por subdivisión" }

---

## Caso de Uso 2: Actualizar área según título para cuenta sin subpredio y diferencia < 10%

**Descripción:** El usuario actualiza el área según título de una cuenta catastral sin subpredio, y la diferencia con el avalúo es menor al 10%.

**Precondiciones:**
La cuenta existe, subpredio = 0, existe avalúo con superficie > 0.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta catastral.
2. El sistema muestra los datos actuales.
3. El usuario ingresa un nuevo valor para área según título (diferencia < 10% respecto a superficie de avalúo).
4. El usuario presiona 'Actualizar'.
5. El sistema valida y actualiza el registro.

**Resultado esperado:**
El área según título se actualiza correctamente.

**Datos de prueba:**
{ "cvecuenta": 54321, "areatitulo": 100.0, "observacion": "Corrección menor" }

---

## Caso de Uso 3: Intentar actualizar área con diferencia > 10%

**Descripción:** El usuario intenta actualizar el área según título, pero la diferencia con el avalúo es mayor al 10%.

**Precondiciones:**
La cuenta existe, subpredio = 0, existe avalúo con superficie > 0.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta catastral.
2. El sistema muestra los datos actuales.
3. El usuario ingresa un nuevo valor para área según título (diferencia > 10% respecto a superficie de avalúo).
4. El usuario presiona 'Actualizar'.
5. El sistema rechaza la operación y muestra mensaje de error.

**Resultado esperado:**
El sistema muestra un mensaje de error y no actualiza el registro.

**Datos de prueba:**
{ "cvecuenta": 54321, "areatitulo": 50.0, "observacion": "Intento de reducción excesiva" }

---

