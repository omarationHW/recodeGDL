# Casos de Uso - cvecatfrm

**Categoría:** Form

## Caso de Uso 1: Cambio de clave catastral con validación exitosa

**Descripción:** El usuario desea cambiar la clave catastral de una cuenta vigente, cumpliendo todas las reglas de validación.

**Precondiciones:**
El usuario tiene permisos y la cuenta no está bloqueada ni cancelada.

**Pasos a seguir:**
1. El usuario accede a la página de clave catastral para la cuenta 12345.
2. Visualiza los datos actuales.
3. Ingresa una nueva clave catastral válida (ejemplo: D65H3123456) y subpredio 2.
4. Presiona 'Cambiar'.
5. El sistema valida la clave, verifica que la manzana no esté bloqueada y actualiza la información.

**Resultado esperado:**
La clave catastral y subpredio se actualizan correctamente. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 12345, "clave": "D65H3123456", "subpredio": 2 }

---

## Caso de Uso 2: Intento de cambio con clave catastral ya existente

**Descripción:** El usuario intenta asignar una clave catastral que ya está en uso para otro predio.

**Precondiciones:**
Existe otra cuenta con la clave catastral D66A0123456.

**Pasos a seguir:**
1. El usuario accede a la página de clave catastral para la cuenta 54321.
2. Ingresa la clave D66A0123456 y subpredio vacío.
3. Presiona 'Cambiar'.

**Resultado esperado:**
El sistema muestra error indicando que la clave ya está en uso.

**Datos de prueba:**
{ "cvecuenta": 54321, "clave": "D66A0123456", "subpredio": null }

---

## Caso de Uso 3: Bloqueo por manzana bloqueada

**Descripción:** El usuario intenta cambiar la clave catastral de una cuenta cuya manzana está bloqueada.

**Precondiciones:**
La manzana D65H31234 está bloqueada en c_manzanas.

**Pasos a seguir:**
1. El usuario accede a la página de clave catastral para la cuenta 67890.
2. Ingresa la clave D65H3123456 y subpredio 1.
3. Presiona 'Cambiar'.

**Resultado esperado:**
El sistema muestra error indicando que la manzana está bloqueada y no permite el cambio.

**Datos de prueba:**
{ "cvecuenta": 67890, "clave": "D65H3123456", "subpredio": 1 }

---

