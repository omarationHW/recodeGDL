# Casos de Uso - reactivafrm

**Categoría:** Form

## Caso de Uso 1: Reactivar una cuenta cancelada

**Descripción:** El usuario necesita reactivar una cuenta catastral que fue cancelada por error.

**Precondiciones:**
La cuenta existe y tiene vigente = 'C'. El usuario tiene permisos de reactivación.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta en el formulario.
2. El sistema muestra los datos y el estado 'C'.
3. El usuario presiona el botón 'Reactivar'.
4. El sistema ejecuta el proceso y actualiza los estados.
5. El usuario ve el mensaje de éxito y la cuenta aparece como vigente.

**Resultado esperado:**
La cuenta y sus entidades relacionadas quedan con vigente = 'V'. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 10001 }

---

## Caso de Uso 2: Intentar reactivar una cuenta ya vigente

**Descripción:** El usuario intenta reactivar una cuenta que ya está activa.

**Precondiciones:**
La cuenta existe y tiene vigente = 'V'.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta.
2. El sistema muestra los datos y el estado 'V'.
3. El botón de reactivación está deshabilitado.

**Resultado esperado:**
No se permite la reactivación. El usuario ve que la cuenta ya está vigente.

**Datos de prueba:**
{ "cvecuenta": 10002 }

---

## Caso de Uso 3: Error al reactivar cuenta inexistente

**Descripción:** El usuario intenta reactivar una cuenta que no existe en el sistema.

**Precondiciones:**
La cuenta no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un número de cuenta inexistente.
2. El sistema muestra mensaje de 'Cuenta no encontrada'.

**Resultado esperado:**
No se ejecuta ningún proceso. Se muestra mensaje de error.

**Datos de prueba:**
{ "cvecuenta": 99999 }

---

