# Casos de Uso - muestradupfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de cuentas duplicadas de un condominio

**Descripción:** El usuario desea ver todas las cuentas duplicadas asociadas a un condominio específico.

**Precondiciones:**
El usuario está autenticado y conoce la clave catastral del condominio.

**Pasos a seguir:**
1. El usuario ingresa la clave catastral del condominio en el campo de búsqueda.
2. Presiona el botón 'Buscar'.
3. El sistema consulta el backend y muestra la lista de cuentas duplicadas.

**Resultado esperado:**
Se muestra una tabla con todas las cuentas duplicadas activas (no eliminadas) del condominio.

**Datos de prueba:**
cvecond = 12345 (ejemplo de clave de condominio existente con duplicados)

---

## Caso de Uso 2: Eliminación de una cuenta duplicada

**Descripción:** El usuario identifica una cuenta duplicada incorrecta y desea eliminarla del listado.

**Precondiciones:**
El usuario ha realizado una búsqueda y visualiza la lista de duplicados.

**Pasos a seguir:**
1. El usuario localiza la cuenta duplicada en la tabla.
2. Presiona el botón 'Eliminar' junto a la cuenta.
3. Confirma la eliminación en el diálogo de confirmación.
4. El sistema actualiza el estado de la cuenta a 'D' (eliminada) y refresca la lista.

**Resultado esperado:**
La cuenta desaparece del listado y no puede ser integrada.

**Datos de prueba:**
cvecuenta = 56789 (ejemplo de cuenta duplicada activa)

---

## Caso de Uso 3: Aplicación de integración de subpredios

**Descripción:** El usuario desea cerrar el proceso de integración de subpredios, validando que todo esté correcto.

**Precondiciones:**
El usuario ha revisado la lista de duplicados y está listo para integrar.

**Pasos a seguir:**
1. El usuario presiona el botón 'Aplicar Integración'.
2. El sistema ejecuta las validaciones en el backend (suma de indivisos, número de subpredios, duplicados).
3. Si todo es correcto, se marca el condominio como integrado y se registra la fecha y usuario.

**Resultado esperado:**
El sistema muestra un mensaje de éxito y la integración queda registrada. Si hay errores, se muestra el mensaje correspondiente.

**Datos de prueba:**
cvecond = 12345 (con subpredios correctos y suma de indivisos = 100)

---

