# Casos de Uso - BloquearLicenciafrm

**Categoría:** Form

## Caso de Uso 1: Bloquear una licencia por incumplimiento

**Descripción:** El usuario busca una licencia vigente y la bloquea por un motivo específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de bloqueo. La licencia existe y está vigente.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y presiona Buscar.
- El sistema muestra los datos de la licencia y su estado.
- El usuario hace clic en 'Bloquear licencia'.
- Selecciona el tipo de bloqueo (por ejemplo, 'BLOQUEADO').
- Escribe el motivo (por ejemplo, 'Incumplimiento de requisitos').
- Confirma la operación.
- El sistema ejecuta el SP y actualiza el estado.

**Resultado esperado:**
La licencia queda bloqueada, el movimiento aparece en el histórico y el estado cambia a 'BLOQUEADO'.

**Datos de prueba:**
{ "licencia": 12345, "tipo_bloqueo": 1, "motivo": "Incumplimiento de requisitos" }

---

## Caso de Uso 2: Desbloquear una licencia con bloqueo activo

**Descripción:** El usuario desbloquea una licencia que tiene bloqueos activos.

**Precondiciones:**
El usuario está autenticado. La licencia tiene al menos un bloqueo activo.

**Pasos a seguir:**
- El usuario busca la licencia bloqueada.
- El sistema muestra los bloqueos activos.
- El usuario selecciona el bloqueo a eliminar y escribe el motivo.
- Confirma la operación.
- El sistema ejecuta el SP y actualiza el estado.

**Resultado esperado:**
La licencia queda desbloqueada (o con el siguiente bloqueo activo si hay más de uno). El movimiento aparece en el histórico.

**Datos de prueba:**
{ "licencia": 12345, "tipo_bloqueo": 1, "motivo": "Cumplió requisitos" }

---

## Caso de Uso 3: Intentar bloquear una licencia ya bloqueada

**Descripción:** El usuario intenta bloquear una licencia que ya tiene un bloqueo activo del mismo tipo.

**Precondiciones:**
La licencia ya tiene un bloqueo activo del tipo seleccionado.

**Pasos a seguir:**
- El usuario busca la licencia.
- Intenta bloquearla con el mismo tipo de bloqueo.
- El sistema valida y rechaza la operación.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'La licencia ya está bloqueada por el mismo tipo'.

**Datos de prueba:**
{ "licencia": 12345, "tipo_bloqueo": 1, "motivo": "Duplicado" }

---

