# Casos de Prueba para ZonaAnuncio

## Caso 1: Crear zona para anuncio nuevo
- **Entrada:** { "anuncio": 2001, "zona": 1, "subzona": 2, "recaud": 3 }
- **Acción:** zonaanuncio.create
- **Esperado:** Registro creado en anuncios_zona, respuesta success.

## Caso 2: Actualizar zona de anuncio existente
- **Precondición:** El anuncio 2001 tiene registro en anuncios_zona.
- **Entrada:** { "anuncio": 2001, "zona": 2, "subzona": 4, "recaud": 1 }
- **Acción:** zonaanuncio.update
- **Esperado:** Registro actualizado, respuesta success.

## Caso 3: Obtener zona de anuncio
- **Entrada:** { "anuncio": 2001 }
- **Acción:** zonaanuncio.get
- **Esperado:** Devuelve datos actuales de zona, subzona y recaud.

## Caso 4: Eliminar zona de anuncio
- **Entrada:** { "anuncio": 2001 }
- **Acción:** zonaanuncio.delete
- **Esperado:** Registro eliminado, respuesta success.

## Caso 5: Validación de campos obligatorios
- **Entrada:** { "anuncio": null, "zona": null, "subzona": null, "recaud": null }
- **Acción:** zonaanuncio.create
- **Esperado:** Error de validación, respuesta 422.

## Caso 6: Catálogos
- **Entrada:** {}
- **Acción:** zonaanuncio.catalogs
- **Esperado:** Devuelve listas de zonas, subzonas y recaudadoras.
