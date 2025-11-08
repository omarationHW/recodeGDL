# Casos de Prueba: Baja de Anuncio

## Caso 1: Baja exitosa de anuncio sin adeudos
- Ingresar número de anuncio válido, vigente y sin adeudos
- Ingresar motivo, año y folio
- Presionar 'Dar de baja'
- Verificar que el anuncio queda cancelado y los adeudos se actualizan

## Caso 2: Intento de baja con adeudos
- Ingresar número de anuncio con adeudos activos
- Verificar que el botón de baja está deshabilitado y se muestra advertencia

## Caso 3: Baja por error (usuario especial)
- Ingresar como usuario con permisos especiales
- Buscar anuncio vigente y sin adeudos
- Marcar 'Baja por error' y dar de baja
- Verificar que no se requieren año/folio y la baja se realiza

## Caso 4: Baja de anuncio ya cancelado
- Ingresar número de anuncio ya cancelado
- Verificar que se muestra mensaje de advertencia y no se permite baja

## Caso 5: Validación de campos obligatorios
- Intentar dar de baja sin ingresar año/folio (sin marcar baja por error/tiempo)
- Verificar que se muestra mensaje de error y no se procesa la baja
