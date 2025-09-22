# Casos de Uso - observaTransmfrm

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva observación de bloqueo

**Descripción:** Un usuario necesita bloquear una transmisión patrimonial agregando una observación.

**Precondiciones:**
El usuario tiene permisos y conoce el folio y noControl.

**Pasos a seguir:**
1. El usuario ingresa al formulario de Observaciones.
2. Ingresa el No. Control, Clave Cuenta, Folio, Observación y su usuario.
3. Presiona 'Registrar'.
4. El sistema envía la petición a /api/execute con action 'create'.

**Resultado esperado:**
La observación se registra, la transmisión queda bloqueada (status 'B'), y aparece en el listado.

**Datos de prueba:**
{
  "nocontrol": 12345,
  "cvecuenta": 67890,
  "folio": 20231234,
  "observacion": "Se bloquea por falta de documentos.",
  "usuario": "jdoe"
}

---

## Caso de Uso 2: Desbloquear una transmisión patrimonial

**Descripción:** Un usuario necesita desbloquear una transmisión previamente bloqueada.

**Precondiciones:**
Existe una observación con status 'B' para el folio y noControl.

**Pasos a seguir:**
1. El usuario localiza la observación en el listado.
2. Presiona el botón 'Desbloquear'.
3. El sistema solicita confirmación y envía la petición a /api/execute con action 'unlock'.

**Resultado esperado:**
La observación cambia a status 'D', se registra la fecha y usuario de baja.

**Datos de prueba:**
{
  "nocontrol": 12345,
  "folio": 20231234,
  "observacion": "Se desbloquea por entrega de documentos.",
  "usuario": "jdoe"
}

---

## Caso de Uso 3: Listar observaciones de un folio

**Descripción:** Un usuario desea consultar todas las observaciones asociadas a un folio.

**Precondiciones:**
Existen observaciones registradas para el folio.

**Pasos a seguir:**
1. El usuario ingresa el folio en el campo de búsqueda.
2. El sistema envía la petición a /api/execute con action 'list'.

**Resultado esperado:**
Se muestra el listado de observaciones para ese folio.

**Datos de prueba:**
{
  "folio": 20231234
}

---

