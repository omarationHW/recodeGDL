# Casos de Prueba: ReactivaTramite

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Reactivar trámite cancelado | id_tramite=12345 (estatus 'C'), motivo='Motivo de prueba' | Respuesta success=true, mensaje='Trámite reactivado correctamente.', estatus del trámite='T', revisiones='V' |
| 2 | Reactivar trámite rechazado | id_tramite=23456 (estatus 'R'), motivo='Motivo de prueba' | Respuesta success=true, mensaje='Trámite reactivado correctamente.', estatus del trámite='T', revisiones='V' |
| 3 | Intentar reactivar trámite aprobado | id_tramite=54321 (estatus 'A'), motivo='...' | Respuesta success=false, mensaje='El trámite ya se encuentra aprobado. No se puede reactivar.' |
| 4 | Intentar reactivar trámite en estatus inválido | id_tramite=34567 (estatus 'T'), motivo='...' | Respuesta success=false, mensaje='El trámite no se encuentra cancelado o rechazado.' |
| 5 | Buscar trámite inexistente | id_tramite=99999 | Respuesta success=false, mensaje='Trámite no encontrado.' |
| 6 | Reactivar trámite sin motivo | id_tramite=12345 (estatus 'C'), motivo='' | Respuesta success=false, mensaje='Debe ingresar un motivo' (validación frontend) |
