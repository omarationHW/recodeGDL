# Casos de Prueba: Cancelación de Trámites

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| 1 | Consulta de trámite existente | id_tramite = 1001 | Se muestran todos los datos del trámite y giro |
| 2 | Consulta de trámite inexistente | id_tramite = 9999 | Mensaje: 'No se encontró el trámite.' |
| 3 | Cancelación exitosa | id_tramite = 1003, motivo = 'El solicitante lo pidió' | Mensaje: 'Trámite cancelado exitosamente.'; estatus = 'C' |
| 4 | Cancelar trámite ya cancelado | id_tramite = 1002, motivo = 'Prueba' | Mensaje: 'El trámite ya se encuentra cancelado.'; estatus = 'C' |
| 5 | Cancelar trámite aprobado | id_tramite = 1004 (estatus = 'A'), motivo = 'Prueba' | Mensaje: 'El trámite ya se encuentra aprobado. No se puede cancelar.'; estatus = 'A' |
| 6 | Cancelar trámite sin motivo | id_tramite = 1003, motivo = '' | Mensaje: 'Debe ingresar el motivo de la cancelación.' |
