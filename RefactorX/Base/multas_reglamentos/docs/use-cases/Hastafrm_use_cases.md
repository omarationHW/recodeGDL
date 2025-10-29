# Casos de Uso - Hastafrm

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de formulario 'Pagar hasta'

**Descripción:** El usuario ingresa un bimestre y año válidos y el sistema valida correctamente.

**Precondiciones:**
El usuario accede a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '2' en el campo Bimestre.
2. El usuario ingresa '2024' en el campo Año.
3. El usuario presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de éxito: 'Formulario validado correctamente.' y los datos son aceptados.

**Datos de prueba:**
{ "bimestre": 2, "anio": 2024 }

---

## Caso de Uso 2: Error por bimestre fuera de rango

**Descripción:** El usuario ingresa un bimestre inválido (por ejemplo, 7) y el sistema rechaza la entrada.

**Precondiciones:**
El usuario accede a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '7' en el campo Bimestre.
2. El usuario ingresa '2024' en el campo Año.
3. El usuario presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error: 'El bimestre solo puede ser de 1 a 6.' y no acepta los datos.

**Datos de prueba:**
{ "bimestre": 7, "anio": 2024 }

---

## Caso de Uso 3: Cancelación del formulario

**Descripción:** El usuario decide cancelar la operación y el sistema pone los valores de salida y muestra mensaje de cancelación.

**Precondiciones:**
El usuario accede a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario presiona el botón 'Cancelar'.

**Resultado esperado:**
El sistema pone bimestre=9, año=9999 y muestra mensaje 'Operación cancelada.'

**Datos de prueba:**
N/A (acción de UI)

---

