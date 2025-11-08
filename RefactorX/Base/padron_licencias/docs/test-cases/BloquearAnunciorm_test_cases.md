# Casos de Prueba para BloquearAnunciorm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Buscar anuncio existente | numero_anuncio = '12345' | Devuelve datos del anuncio y su estado |
| TC02 | Buscar anuncio inexistente | numero_anuncio = '99999' | Mensaje: 'No se encontró licencia con ese número' |
| TC03 | Bloquear anuncio no bloqueado | numero_anuncio = '12345', motivo = 'Incumplimiento', usuario = 'admin' | Estado cambia a BLOQUEADO, historial actualizado |
| TC04 | Bloquear anuncio ya bloqueado | numero_anuncio = '54321', usuario = 'admin' | Mensaje de error: 'El anuncio ya está bloqueado, no se puede bloquear' |
| TC05 | Desbloquear anuncio bloqueado | numero_anuncio = '67890', motivo = 'Revisión aprobada', usuario = 'admin' | Estado cambia a NO BLOQUEADO, historial actualizado |
| TC06 | Desbloquear anuncio no bloqueado | numero_anuncio = '12345', usuario = 'admin' | Mensaje de error: 'El anuncio no está bloqueado, no se puede desbloquear' |
| TC07 | Consultar historial de bloqueos | numero_anuncio = '12345' | Tabla de movimientos muestra todos los bloqueos/desbloqueos |
| TC08 | Bloquear anuncio sin motivo | numero_anuncio = '12345', motivo = '', usuario = 'admin' | Mensaje de error: 'El motivo es obligatorio' (validación frontend) |
