# Casos de Prueba: BloquearTramitefrm

## Caso 1: Consulta de trámite inexistente
- **Entrada:** id_tramite = 999999
- **Acción:** Buscar trámite
- **Resultado esperado:** Mensaje de error 'No se encontró trámite con ese número'.

## Caso 2: Consulta de trámite existente sin bloqueos
- **Entrada:** id_tramite = 2001 (sin registros en bloqueo)
- **Acción:** Buscar trámite
- **Resultado esperado:** Se muestran los datos del trámite y el historial de bloqueos está vacío.

## Caso 3: Bloqueo exitoso de trámite
- **Entrada:** id_tramite = 2002 (bloqueado = 0), observa = 'Prueba bloqueo', capturista = 'tester'
- **Acción:** Buscar trámite, luego bloquear trámite e ingresar motivo.
- **Resultado esperado:** Mensaje de éxito, trámite bloqueado, historial actualizado con nuevo registro.

## Caso 4: Desbloqueo exitoso de trámite
- **Entrada:** id_tramite = 2003 (bloqueado = 1), observa = 'Prueba desbloqueo', capturista = 'tester'
- **Acción:** Buscar trámite, luego desbloquear trámite e ingresar motivo.
- **Resultado esperado:** Mensaje de éxito, trámite desbloqueado, historial actualizado con nuevo registro.

## Caso 5: Intento de bloquear trámite ya bloqueado
- **Entrada:** id_tramite = 2003 (bloqueado = 1)
- **Acción:** Buscar trámite, intentar bloquear trámite
- **Resultado esperado:** Botón de bloqueo deshabilitado, no se permite la acción.

## Caso 6: Intento de desbloquear trámite no bloqueado
- **Entrada:** id_tramite = 2002 (bloqueado = 0)
- **Acción:** Buscar trámite, intentar desbloquear trámite
- **Resultado esperado:** Botón de desbloqueo deshabilitado, no se permite la acción.

## Caso 7: Cancelación de prompt de motivo
- **Entrada:** id_tramite = 2002, acción de bloquear/desbloquear, usuario cancela el prompt
- **Acción:** Cancelar el prompt de motivo
- **Resultado esperado:** No se realiza ninguna acción, estado sin cambios.
