# Casos de Uso - ReactivaTramite

**Categoría:** Form

## Caso de Uso 1: Reactivar un trámite cancelado

**Descripción:** Un usuario busca un trámite con estatus 'C' (cancelado) y lo reactiva proporcionando un motivo.

**Precondiciones:**
El trámite existe y su estatus es 'C'.

**Pasos a seguir:**
1. El usuario accede a la página de Reactivación de Trámites.
2. Ingresa el número de trámite (por ejemplo, 12345) y presiona Buscar.
3. El sistema muestra los datos del trámite.
4. El usuario hace clic en 'Reactivar'.
5. Ingresa el motivo de reactivación y confirma.
6. El sistema actualiza el trámite y muestra mensaje de éxito.

**Resultado esperado:**
El trámite cambia su estatus a 'T' y las revisiones asociadas a 'V'. Se muestra mensaje de éxito.

**Datos de prueba:**
id_tramite: 12345 (estatus: 'C')

---

## Caso de Uso 2: Intentar reactivar un trámite aprobado

**Descripción:** El usuario intenta reactivar un trámite que ya está aprobado (estatus 'A').

**Precondiciones:**
El trámite existe y su estatus es 'A'.

**Pasos a seguir:**
1. El usuario ingresa el número de trámite (por ejemplo, 54321) y presiona Buscar.
2. El sistema muestra los datos del trámite.
3. El usuario intenta hacer clic en 'Reactivar'.

**Resultado esperado:**
El botón de reactivar está deshabilitado y se muestra mensaje indicando que no se puede reactivar.

**Datos de prueba:**
id_tramite: 54321 (estatus: 'A')

---

## Caso de Uso 3: Buscar un trámite inexistente

**Descripción:** El usuario busca un trámite que no existe en la base de datos.

**Precondiciones:**
El trámite no existe.

**Pasos a seguir:**
1. El usuario ingresa un número de trámite inexistente (por ejemplo, 99999) y presiona Buscar.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que el trámite no fue encontrado.

**Datos de prueba:**
id_tramite: 99999 (no existe)

---

