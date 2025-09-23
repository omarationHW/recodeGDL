# Casos de Uso - bajaAnunciofrm

**Categoría:** Form

## Caso de Uso 1: Baja de anuncio vigente sin adeudos

**Descripción:** El usuario da de baja un anuncio que está vigente y no tiene adeudos.

**Precondiciones:**
El usuario tiene permisos para dar de baja anuncios. El anuncio existe, está vigente y no tiene adeudos.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra los datos del anuncio y confirma que no tiene adeudos.
3. El usuario ingresa el motivo, año y folio de baja.
4. El usuario presiona 'Dar de baja'.
5. El sistema procesa la baja y muestra mensaje de éxito.

**Resultado esperado:**
El anuncio queda con estado 'C' (cancelado), los adeudos se cancelan y el saldo de la licencia se recalcula.

**Datos de prueba:**
{ anuncio: 12345, motivo: 'Cierre de negocio', axo_baja: 2024, folio_baja: 1001, usuario: 'admin', baja_error: false, baja_tiempo: false }

---

## Caso de Uso 2: Intento de baja de anuncio con adeudos

**Descripción:** El usuario intenta dar de baja un anuncio que tiene adeudos activos.

**Precondiciones:**
El usuario tiene permisos. El anuncio existe, está vigente pero tiene adeudos.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra los datos y la lista de adeudos.
3. El botón 'Dar de baja' está deshabilitado.

**Resultado esperado:**
No se permite la baja. El sistema muestra mensaje de advertencia.

**Datos de prueba:**
{ anuncio: 54321 }

---

## Caso de Uso 3: Baja de anuncio por error (usuario con permisos especiales)

**Descripción:** Un usuario con permisos especiales realiza una baja por error sin requerir año/folio.

**Precondiciones:**
El usuario pertenece a la dependencia 30 y tiene nivel > 1. El anuncio está vigente y sin adeudos.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra los datos y la opción 'Baja por error'.
3. El usuario marca 'Baja por error' y presiona 'Dar de baja'.
4. El sistema procesa la baja sin requerir año/folio.

**Resultado esperado:**
El anuncio queda cancelado y se registra como baja por error.

**Datos de prueba:**
{ anuncio: 67890, motivo: 'Error administrativo', axo_baja: null, folio_baja: null, usuario: 'supervisor', baja_error: true, baja_tiempo: false }

---

