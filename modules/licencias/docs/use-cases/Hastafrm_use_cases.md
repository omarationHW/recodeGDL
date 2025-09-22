# Casos de Uso - Hastafrm

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de bimestre y año

**Descripción:** El usuario ingresa un bimestre y año válidos y la operación es aceptada.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '2' en el campo Bimestre.
2. El usuario ingresa '2024' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema valida los datos, muestra mensaje de éxito y permite continuar.

**Datos de prueba:**
{ "bimestre": 2, "anio": 2024 }

---

## Caso de Uso 2: Error por bimestre fuera de rango

**Descripción:** El usuario ingresa un bimestre inválido (por ejemplo, 7) y la operación es rechazada.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '7' en el campo Bimestre.
2. El usuario ingresa '2023' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el bimestre es inválido.

**Datos de prueba:**
{ "bimestre": 7, "anio": 2023 }

---

## Caso de Uso 3: Cancelación de la operación

**Descripción:** El usuario decide cancelar la operación y el formulario se resetea con valores especiales.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario hace clic en 'Cancelar'.

**Resultado esperado:**
El formulario asigna bimestre=9 y año=9999, mostrando mensaje de cancelación.

**Datos de prueba:**
{ "bimestre": 9, "anio": 9999 }

---

