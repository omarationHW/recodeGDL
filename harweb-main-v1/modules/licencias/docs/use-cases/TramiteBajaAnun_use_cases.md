# Casos de Uso - TramiteBajaAnun

**Categoría:** Form

## Caso de Uso 1: Tramitar baja de anuncio vigente sin adeudos

**Descripción:** El usuario tramita la baja de un anuncio que está vigente y no tiene adeudos.

**Precondiciones:**
El anuncio existe, está vigente (vigente='V'), y no tiene adeudos en detsal_lic.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio en la página de baja.
2. El sistema muestra los datos del anuncio y confirma que no hay adeudos.
3. El usuario ingresa el motivo de la baja y confirma la acción.
4. El sistema ejecuta el stored procedure para cancelar el anuncio, cancelar adeudos y registrar la baja.

**Resultado esperado:**
El anuncio queda cancelado, los adeudos se marcan como cancelados, y se registra la baja en lic_cancel.

**Datos de prueba:**
{ "anuncio": 12345, "motivo": "Cierre de negocio", "usuario": "admin", "axo_baja": 2024, "folio_baja": 1 }

---

## Caso de Uso 2: Intentar tramitar baja de anuncio ya cancelado

**Descripción:** El usuario intenta tramitar la baja de un anuncio que ya está cancelado.

**Precondiciones:**
El anuncio existe pero su campo vigente <> 'V'.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio cancelado.
2. El sistema muestra mensaje de error indicando que ya está cancelado.

**Resultado esperado:**
No se realiza ninguna acción y se muestra error.

**Datos de prueba:**
{ "anuncio": 54321, "motivo": "Duplicado", "usuario": "admin" }

---

## Caso de Uso 3: Tramitar baja de anuncio con adeudos usando permiso especial

**Descripción:** El usuario con permiso especial tramita la baja de un anuncio con adeudos.

**Precondiciones:**
El anuncio existe, está vigente, tiene adeudos, y el usuario tiene permiso para baja por error o fuera de tiempo.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio con adeudos.
2. El sistema muestra los adeudos y permite la baja por error/tiempo.
3. El usuario marca la opción de baja por error y confirma la acción.
4. El sistema ejecuta el stored procedure y tramita la baja.

**Resultado esperado:**
El anuncio queda cancelado y se registra la baja, aunque existían adeudos.

**Datos de prueba:**
{ "anuncio": 67890, "motivo": "Error administrativo", "usuario": "supervisor", "baja_error": true }

---

