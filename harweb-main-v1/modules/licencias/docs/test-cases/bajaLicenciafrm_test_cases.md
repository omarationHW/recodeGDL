# Casos de Prueba: Baja de Licencia

## Caso 1: Baja exitosa sin adeudos
- Ingresar licencia válida y vigente sin adeudos ni anuncios bloqueados
- Ingresar motivo, año y folio
- Confirmar baja
- Verificar en BD que licencia y anuncios quedan con vigente = 'C', adeudos cvepago = 999999

## Caso 2: Baja rechazada por anuncio bloqueado
- Ingresar licencia con al menos un anuncio ligado bloqueado
- Intentar baja
- El sistema debe mostrar mensaje de error y no modificar la BD

## Caso 3: Baja por error administrativa
- Ingresar licencia válida y vigente
- Marcar 'Baja por error'
- Ingresar motivo
- Confirmar baja
- Verificar que la baja se realiza sin requerir año/folio y se registra en bitácora

## Caso 4: Baja de licencia ya cancelada
- Ingresar licencia con vigente <> 'V'
- Intentar baja
- El sistema debe rechazar la operación

## Caso 5: Baja con adeudos y usuario no autorizado
- Ingresar licencia con adeudos
- Usuario sin permisos intenta baja
- El sistema debe rechazar la operación
