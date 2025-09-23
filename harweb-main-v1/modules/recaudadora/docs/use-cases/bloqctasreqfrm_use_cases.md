# Casos de Uso - bloqctasreqfrm

**Categoría:** Form

## Caso de Uso 1: Bloquear una cuenta para requerir

**Descripción:** El usuario bloquea una cuenta para que no sea requerida fiscalmente.

**Precondiciones:**
El usuario está autenticado y conoce los datos de la cuenta.

**Pasos a seguir:**
1. El usuario ingresa recaudadora, urbrus y cuenta.
2. El usuario da clic en 'Buscar'.
3. El sistema muestra los datos de la cuenta y su estado.
4. El usuario ingresa el motivo y la fecha de desbloqueo.
5. El usuario da clic en 'Bloquear'.
6. El sistema ejecuta el bloqueo y muestra mensaje de éxito.

**Resultado esperado:**
La cuenta queda bloqueada y aparece en el historial.

**Datos de prueba:**
{ "recaud": 1, "urbrus": "U", "cuenta": 12345, "motivo": "Cuenta con inconsistencias", "fecha_desbloqueo": "2024-06-30", "usuario": "admin" }

---

## Caso de Uso 2: Desbloquear una cuenta previamente bloqueada

**Descripción:** El usuario desbloquea una cuenta para que pueda ser requerida nuevamente.

**Precondiciones:**
La cuenta está bloqueada y el usuario está autenticado.

**Pasos a seguir:**
1. El usuario busca la cuenta bloqueada.
2. El sistema muestra el estado 'Bloqueada'.
3. El usuario ingresa el motivo de desbloqueo y la fecha.
4. El usuario da clic en 'Desbloquear'.
5. El sistema actualiza el registro y muestra mensaje de éxito.

**Resultado esperado:**
La cuenta queda desbloqueada y el movimiento aparece en el historial.

**Datos de prueba:**
{ "recaud": 1, "urbrus": "U", "cuenta": 12345, "motivo": "Cuenta regularizada", "fecha_desbloqueo": "2024-07-01", "usuario": "admin" }

---

## Caso de Uso 3: Enviar cuentas bloqueadas a Catastro/Inconformidades

**Descripción:** El usuario envía todas las cuentas bloqueadas de una recaudadora a Catastro.

**Precondiciones:**
El usuario tiene permisos y existen cuentas bloqueadas sin enviar.

**Pasos a seguir:**
1. El usuario selecciona la recaudadora.
2. El usuario da clic en 'Enviar a Catastro'.
3. El sistema ejecuta el stored procedure y muestra cuántas cuentas fueron enviadas.

**Resultado esperado:**
Las cuentas quedan marcadas con lote_envio y fecha_envio.

**Datos de prueba:**
{ "usuario": "admin", "recaud": 1 }

---

