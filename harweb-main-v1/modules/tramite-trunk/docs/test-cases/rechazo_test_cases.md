# Casos de Prueba: Rechazo de Transmisión Patrimonial

## Caso 1: Rechazo exitoso
- **Entrada:**
  - folio: 12345
  - motivo: "DOCUMENTACIÓN INCOMPLETA"
  - usuario: "admin"
- **Acción:** rechazar_transmision
- **Esperado:**
  - eResponse.success = true
  - eResponse.message = "Transmisión rechazada correctamente."
  - En la base de datos, actostransm.status = 'R', axocomp = 9999, nocomp = 999999, documentosotros = motivo, usuario_rechazo = usuario, fecha_rechazo ≈ now()

## Caso 2: Rechazo de folio inexistente
- **Entrada:**
  - folio: 99999 (no existe)
  - motivo: "NO EXISTE"
  - usuario: "admin"
- **Acción:** rechazar_transmision
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = "Folio no encontrado."

## Caso 3: Rechazo duplicado
- **Entrada:**
  - folio: 12345 (ya rechazado)
  - motivo: "RECHAZO DUPLICADO"
  - usuario: "admin"
- **Acción:** rechazar_transmision
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = "La transmisión ya está rechazada."

## Caso 4: Consulta de motivo de rechazo
- **Entrada:**
  - folio: 12345
- **Acción:** get_motivo_rechazo
- **Esperado:**
  - eResponse.success = true
  - eResponse.motivo = "DOCUMENTACIÓN INCOMPLETA"
  - eResponse.fecha_rechazo ≈ fecha de rechazo
  - eResponse.usuario = "admin"

## Caso 5: Consulta de motivo de rechazo para folio no rechazado
- **Entrada:**
  - folio: 54321 (no rechazado)
- **Acción:** get_motivo_rechazo
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = "No se encontró motivo de rechazo para el folio."
