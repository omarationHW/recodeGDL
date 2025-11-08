# Casos de Uso - cancelaTramitefrm

**Categoría:** Form

## Caso de Uso 1: Consulta de trámite existente

**Descripción:** El usuario ingresa el número de trámite y visualiza todos los datos asociados.

**Precondiciones:**
El trámite con el ID proporcionado existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de cancelación de trámites.
2. Ingresa el número de trámite en el campo correspondiente.
3. Presiona Enter o el botón Buscar.
4. El sistema muestra los datos del trámite y del giro asociado.

**Resultado esperado:**
Se muestran todos los datos del trámite, incluyendo propietario, ubicación, actividad, giro, etc.

**Datos de prueba:**
id_tramite: 1001 (existente en la tabla tramites)

---

## Caso de Uso 2: Intento de cancelar trámite ya cancelado

**Descripción:** El usuario intenta cancelar un trámite que ya tiene estatus 'C' (cancelado).

**Precondiciones:**
El trámite existe y su estatus es 'C'.

**Pasos a seguir:**
1. El usuario busca el trámite por su número.
2. El sistema muestra los datos y el botón 'Dar de baja' está deshabilitado.
3. El usuario no puede proceder a cancelar.

**Resultado esperado:**
El sistema informa que el trámite ya está cancelado y no permite la acción.

**Datos de prueba:**
id_tramite: 1002 (estatus = 'C')

---

## Caso de Uso 3: Cancelación exitosa de trámite

**Descripción:** El usuario cancela un trámite válido, ingresando el motivo correspondiente.

**Precondiciones:**
El trámite existe y su estatus no es 'C' ni 'A'.

**Pasos a seguir:**
1. El usuario busca el trámite por su número.
2. El sistema muestra los datos y el botón 'Dar de baja' está habilitado.
3. El usuario hace clic en 'Dar de baja'.
4. Ingresa el motivo en el modal y confirma.
5. El sistema ejecuta la cancelación y actualiza el estatus.

**Resultado esperado:**
El trámite cambia a estatus 'C' y el motivo se almacena correctamente.

**Datos de prueba:**
id_tramite: 1003 (estatus = 'P'), motivo: 'El solicitante lo pidió'

---

