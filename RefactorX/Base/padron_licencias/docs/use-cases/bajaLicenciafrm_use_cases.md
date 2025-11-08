# Casos de Uso - bajaLicenciafrm

**Categoría:** Form

## Caso de Uso 1: Baja de Licencia con Adeudos Pagados

**Descripción:** El usuario da de baja una licencia que no tiene adeudos ni anuncios bloqueados.

**Precondiciones:**
La licencia existe, está vigente, no tiene adeudos ni anuncios bloqueados.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y busca.
- El sistema muestra los datos y confirma que no hay adeudos.
- El usuario ingresa el motivo, año y folio de baja.
- El usuario confirma la baja.
- El sistema ejecuta la baja y muestra mensaje de éxito.

**Resultado esperado:**
La licencia y sus anuncios quedan con estatus cancelado, los adeudos se cancelan y se registra la bitácora.

**Datos de prueba:**
licencia: 12345, motivo: 'Cierre definitivo', anio: 2024, folio: 100

---

## Caso de Uso 2: Intento de Baja con Anuncio Bloqueado

**Descripción:** El usuario intenta dar de baja una licencia pero uno de los anuncios ligados está bloqueado.

**Precondiciones:**
La licencia existe, está vigente, pero al menos un anuncio ligado tiene bloqueado > 0.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y busca.
- El sistema muestra los datos y la lista de anuncios.
- El usuario intenta confirmar la baja.
- El sistema rechaza la operación y muestra mensaje de error.

**Resultado esperado:**
No se realiza la baja y se informa que hay anuncios bloqueados.

**Datos de prueba:**
licencia: 54321, motivo: 'Cierre', anio: 2024, folio: 101

---

## Caso de Uso 3: Baja por Error Administrativa

**Descripción:** Un usuario autorizado realiza la baja por error administrativo, sin requerir año y folio.

**Precondiciones:**
La licencia existe, está vigente, el usuario tiene nivel suficiente y marca baja por error.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y busca.
- El sistema muestra los datos.
- El usuario marca la opción 'Baja por error'.
- El usuario ingresa el motivo y confirma la baja.
- El sistema ejecuta la baja sin requerir año y folio.

**Resultado esperado:**
La licencia queda cancelada, se registra el motivo y la bitácora.

**Datos de prueba:**
licencia: 67890, motivo: 'Captura errónea', baja_error: true

---

