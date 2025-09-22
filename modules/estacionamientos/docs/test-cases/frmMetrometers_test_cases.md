# Casos de Prueba MetroMeters

## Caso 1: Consulta exitosa
- **Entrada:** axo=2023, folio=123456
- **Acción:** Buscar MetroMeter
- **Esperado:** Se muestran los datos completos del registro.

## Caso 2: Consulta con registro inexistente
- **Entrada:** axo=2023, folio=999999
- **Acción:** Buscar MetroMeter
- **Esperado:** Mensaje de error "No se encontró el registro."

## Caso 3: Actualización exitosa
- **Entrada:** axo=2023, folio=123456, direccion="CALLE 123", marca="ACME", motivo="PRUEBA"
- **Acción:** Actualizar MetroMeter
- **Esperado:** Mensaje de éxito y datos actualizados en la base.

## Caso 4: Actualización con campos obligatorios vacíos
- **Entrada:** axo=2023, folio=123456, direccion="", marca="", motivo=""
- **Acción:** Actualizar MetroMeter
- **Esperado:** Mensaje de error de validación.

## Caso 5: Visualización de foto
- **Entrada:** folio="123456", photo_number=1
- **Acción:** Ver Foto 1
- **Esperado:** Se muestra la imagen en base64.

## Caso 6: Visualización de foto con folio inexistente
- **Entrada:** folio="999999", photo_number=1
- **Acción:** Ver Foto 1
- **Esperado:** Mensaje de error o imagen no encontrada.
