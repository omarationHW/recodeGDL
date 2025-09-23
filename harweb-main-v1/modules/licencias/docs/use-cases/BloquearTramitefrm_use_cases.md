# Casos de Uso - BloquearTramitefrm

**Categoría:** Form

## Caso de Uso 1: Consulta de trámite existente y visualización de historial de bloqueos

**Descripción:** El usuario ingresa el número de un trámite existente y visualiza todos los datos relevantes, así como el historial de bloqueos y desbloqueos.

**Precondiciones:**
El trámite con el ID proporcionado existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Bloqueo de Trámites.
2. Ingresa el número de trámite en el campo correspondiente.
3. Presiona Enter o hace clic en 'Buscar'.
4. El sistema muestra los datos del trámite y el historial de bloqueos.

**Resultado esperado:**
Se muestran correctamente los datos del trámite y el historial de bloqueos/desbloqueos.

**Datos de prueba:**
id_tramite: 1001 (existente)

---

## Caso de Uso 2: Bloqueo de un trámite no bloqueado

**Descripción:** El usuario bloquea un trámite que actualmente no está bloqueado, registrando el motivo.

**Precondiciones:**
El trámite existe y su campo 'bloqueado' es 0.

**Pasos a seguir:**
1. El usuario busca el trámite.
2. El botón 'Bloquear trámite' está habilitado.
3. El usuario hace clic en 'Bloquear trámite'.
4. Ingresa el motivo en el prompt.
5. El sistema actualiza el estado y registra el bloqueo.

**Resultado esperado:**
El trámite queda bloqueado, el botón de desbloqueo se habilita y el historial se actualiza.

**Datos de prueba:**
id_tramite: 1002 (bloqueado = 0), observa: 'Falta documentación', capturista: 'admin'

---

## Caso de Uso 3: Desbloqueo de un trámite bloqueado

**Descripción:** El usuario desbloquea un trámite que está actualmente bloqueado, registrando el motivo.

**Precondiciones:**
El trámite existe y su campo 'bloqueado' es 1.

**Pasos a seguir:**
1. El usuario busca el trámite.
2. El botón 'Desbloquear trámite' está habilitado.
3. El usuario hace clic en 'Desbloquear trámite'.
4. Ingresa el motivo en el prompt.
5. El sistema actualiza el estado y registra el desbloqueo.

**Resultado esperado:**
El trámite queda desbloqueado, el botón de bloqueo se habilita y el historial se actualiza.

**Datos de prueba:**
id_tramite: 1003 (bloqueado = 1), observa: 'Documentación recibida', capturista: 'admin'

---

