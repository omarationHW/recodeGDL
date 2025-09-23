# Casos de Prueba: ActualizaDevolucion

## Caso 1: Carga Masiva Exitosa
- Subir archivo con 5 devoluciones válidas.
- Previsualizar y procesar.
- Esperado: 5 insertados, 0 errores.

## Caso 2: Contrato Inexistente
- Subir archivo con 3 devoluciones, una con colonia/calle/folio inexistente.
- Procesar.
- Esperado: 2 insertados, 1 error reportado con mensaje de contrato no encontrado.

## Caso 3: Formato Incorrecto
- Subir archivo con 2 filas, una de solo 10 columnas.
- Procesar.
- Esperado: 1 insertado, 1 error de columnas insuficientes.

## Caso 4: Archivo Vacío
- Subir archivo vacío.
- Procesar.
- Esperado: Mensaje de error 'Archivo no recibido' o 'Sin datos'.

## Caso 5: Usuario sin permisos
- Simular user_id inválido o sin permisos.
- Procesar.
- Esperado: Error de autenticación/autorización (debe implementarse en backend real).
