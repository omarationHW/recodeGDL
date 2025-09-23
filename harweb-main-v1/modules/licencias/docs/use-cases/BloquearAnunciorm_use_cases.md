# Casos de Uso - BloquearAnunciorm

**Categoría:** Form

## Caso de Uso 1: Bloquear un anuncio no bloqueado

**Descripción:** El usuario busca un anuncio existente que no está bloqueado y procede a bloquearlo, registrando el motivo.

**Precondiciones:**
El anuncio existe y su campo 'bloqueado' es 0.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio en el formulario y presiona 'Buscar'.
2. El sistema muestra los datos del anuncio y el estado 'NO BLOQUEADO'.
3. El usuario hace clic en 'Bloquear anuncio'.
4. El sistema solicita el motivo del bloqueo.
5. El usuario ingresa el motivo y confirma.
6. El sistema ejecuta el procedimiento de bloqueo y actualiza el estado y el historial.

**Resultado esperado:**
El anuncio queda bloqueado, el estado cambia a 'BLOQUEADO' y se registra el movimiento en el historial.

**Datos de prueba:**
numero_anuncio: '12345', motivo: 'Incumplimiento de normas', usuario: 'admin'

---

## Caso de Uso 2: Intentar bloquear un anuncio ya bloqueado

**Descripción:** El usuario intenta bloquear un anuncio que ya está bloqueado.

**Precondiciones:**
El anuncio existe y su campo 'bloqueado' es 1.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra el estado 'BLOQUEADO'.
3. El usuario intenta hacer clic en 'Bloquear anuncio'.

**Resultado esperado:**
El botón está deshabilitado o el sistema muestra un mensaje de error indicando que ya está bloqueado.

**Datos de prueba:**
numero_anuncio: '54321', usuario: 'admin'

---

## Caso de Uso 3: Desbloquear un anuncio bloqueado

**Descripción:** El usuario desbloquea un anuncio que está actualmente bloqueado.

**Precondiciones:**
El anuncio existe y su campo 'bloqueado' es 1.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio y presiona 'Buscar'.
2. El sistema muestra el estado 'BLOQUEADO'.
3. El usuario hace clic en 'Desbloquear anuncio'.
4. El sistema solicita el motivo del desbloqueo.
5. El usuario ingresa el motivo y confirma.
6. El sistema ejecuta el procedimiento de desbloqueo y actualiza el estado y el historial.

**Resultado esperado:**
El anuncio queda desbloqueado, el estado cambia a 'NO BLOQUEADO' y se registra el movimiento en el historial.

**Datos de prueba:**
numero_anuncio: '67890', motivo: 'Revisión aprobada', usuario: 'admin'

---

