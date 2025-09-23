# Casos de Uso - LocalesModif

**Categoría:** Form

## Caso de Uso 1: Modificación de Nombre de Local

**Descripción:** El usuario busca un local vigente y modifica el nombre del titular.

**Precondiciones:**
El usuario está autenticado y tiene permisos de modificación. El local existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa los datos de búsqueda (oficina, mercado, categoria, sección, local, letra, bloque) y presiona 'Buscar'.
2. El sistema muestra los datos actuales del local.
3. El usuario edita el campo 'Nombre' y presiona 'Modificar'.
4. El sistema valida y ejecuta la modificación.

**Resultado esperado:**
El nombre del local se actualiza correctamente. Se registra el movimiento en la bitácora.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 10, "categoria": 2, "seccion": "SS", "local": 123, "letra_local": null, "bloque": null, "nombre": "JUAN PEREZ" }

---

## Caso de Uso 2: Bloqueo de Local por Incumplimiento

**Descripción:** El usuario bloquea un local seleccionando la clave de bloqueo y fecha de inicio.

**Precondiciones:**
El usuario está autenticado. El local está vigente y no tiene bloqueo activo.

**Pasos a seguir:**
1. El usuario busca el local.
2. Selecciona el movimiento 'Bloquear'.
3. Selecciona la clave de bloqueo y fecha de inicio.
4. Presiona 'Modificar'.

**Resultado esperado:**
El local queda bloqueado, se inserta registro en ta_11_bloqueo.

**Datos de prueba:**
{ "id_local": 123, "tipo_movimiento": 12, "cve_bloqueo": 5, "fecha_inicio_bloqueo": "2024-07-01", "observacion": "Incumplimiento de pago" }

---

## Caso de Uso 3: Desbloqueo de Local

**Descripción:** El usuario desbloquea un local bloqueado, registrando la fecha final y observación.

**Precondiciones:**
El local tiene un bloqueo activo.

**Pasos a seguir:**
1. El usuario busca el local.
2. Selecciona el movimiento 'Desbloquear'.
3. Selecciona la clave de bloqueo y fecha final.
4. Presiona 'Modificar'.

**Resultado esperado:**
El bloqueo se actualiza con fecha final y observación.

**Datos de prueba:**
{ "id_local": 123, "tipo_movimiento": 13, "cve_bloqueo": 5, "fecha_inicio_bloqueo": "2024-07-01", "fecha_final_bloqueo": "2024-07-15", "observacion": "Pago regularizado" }

---

