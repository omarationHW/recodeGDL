# Casos de Uso - hastafrm

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de bimestre y año

**Descripción:** El usuario ingresa un bimestre y año válidos y la validación es exitosa.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '3' en el campo Bimestre.
2. El usuario ingresa '2023' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Validación exitosa.' y los datos son aceptados.

**Datos de prueba:**
{ "bimestre": 3, "anio": 2023 }

---

## Caso de Uso 2: Error por bimestre fuera de rango

**Descripción:** El usuario ingresa un bimestre inválido (por ejemplo, 7) y el sistema rechaza la entrada.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '7' en el campo Bimestre.
2. El usuario ingresa '2022' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Bimestre inválido!' y no acepta los datos.

**Datos de prueba:**
{ "bimestre": 7, "anio": 2022 }

---

## Caso de Uso 3: Error por año menor a 1970

**Descripción:** El usuario ingresa un año menor a 1970 y el sistema rechaza la entrada.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '2' en el campo Bimestre.
2. El usuario ingresa '1969' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Año inválido!' y no acepta los datos.

**Datos de prueba:**
{ "bimestre": 2, "anio": 1969 }

---

