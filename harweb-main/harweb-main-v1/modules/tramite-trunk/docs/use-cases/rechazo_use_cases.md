# Casos de Uso - rechazo

**Categoría:** Form

## Caso de Uso 1: Rechazo de una transmisión patrimonial por documentación incompleta

**Descripción:** El usuario encargado detecta que la transmisión patrimonial no cumple con los requisitos y decide rechazarla.

**Precondiciones:**
El folio de la transmisión existe y no ha sido previamente rechazada.

**Pasos a seguir:**
1. El usuario accede a la página de rechazo de transmisión.
2. Ingresa el folio (por ejemplo, 12345).
3. Escribe el motivo: 'DOCUMENTACIÓN INCOMPLETA'.
4. Ingresa su usuario: 'admin'.
5. Presiona el botón 'Rechazar Transmisión'.

**Resultado esperado:**
La transmisión es marcada como rechazada, el motivo queda registrado y el usuario recibe confirmación.

**Datos de prueba:**
{ "folio": 12345, "motivo": "DOCUMENTACIÓN INCOMPLETA", "usuario": "admin" }

---

## Caso de Uso 2: Intento de rechazar un folio ya rechazado

**Descripción:** El usuario intenta rechazar una transmisión que ya fue rechazada anteriormente.

**Precondiciones:**
El folio ya tiene status 'R' y axocomp=9999, nocomp=999999.

**Pasos a seguir:**
1. El usuario accede a la página de rechazo.
2. Ingresa el folio ya rechazado.
3. Ingresa un motivo y usuario.
4. Presiona 'Rechazar Transmisión'.

**Resultado esperado:**
El sistema informa que la transmisión ya está rechazada y no realiza ningún cambio.

**Datos de prueba:**
{ "folio": 12345, "motivo": "RECHAZO DUPLICADO", "usuario": "admin" }

---

## Caso de Uso 3: Consulta del motivo de rechazo de una transmisión

**Descripción:** El usuario desea consultar el motivo por el cual una transmisión fue rechazada.

**Precondiciones:**
El folio fue previamente rechazado.

**Pasos a seguir:**
1. El usuario accede a la sección de consulta de motivo de rechazo.
2. Ingresa el folio.
3. Presiona 'Consultar Motivo'.

**Resultado esperado:**
El sistema muestra el motivo, la fecha de rechazo y el usuario responsable.

**Datos de prueba:**
{ "folio": 12345 }

---

