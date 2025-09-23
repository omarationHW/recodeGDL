# Casos de Prueba para Metrometers

## Caso 1: Consulta exitosa de datos generales
- **Entrada:** axo=2024, folio=12345
- **Acción:** Buscar en la página principal
- **Esperado:** Se muestran los datos generales del registro

## Caso 2: Consulta de registro inexistente
- **Entrada:** axo=2024, folio=99999
- **Acción:** Buscar en la página principal
- **Esperado:** Mensaje de error "No se encontraron datos para los parámetros indicados."

## Caso 3: Visualización de Foto 1 válida
- **Entrada:** axo=2024, folio=12345, photo_number=1
- **Acción:** Acceder a la página de Foto 1
- **Esperado:** Se muestra la imagen correctamente

## Caso 4: Visualización de Foto 2 sin URL
- **Entrada:** axo=2024, folio=12345, photo_number=2 (donde linkfoto2 es NULL o vacío)
- **Acción:** Acceder a la página de Foto 2
- **Esperado:** Mensaje de error o imagen no disponible

## Caso 5: Visualización de mapa con coordenadas inválidas
- **Entrada:** axo=2024, folio=54321 (registro sin poslat o poslong)
- **Acción:** Acceder a la página de Mapa
- **Esperado:** Mensaje de error o mapa no disponible
