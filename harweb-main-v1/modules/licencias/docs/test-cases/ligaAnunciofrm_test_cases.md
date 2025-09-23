# Casos de Prueba: Liga de Anuncios a Licencias

## Caso 1: Ligar anuncio a licencia vigente
- Ingresar licencia válida y vigente
- Ingresar anuncio válido y vigente
- Click en 'Ligar Anuncio'
- Esperar mensaje de éxito

## Caso 2: Ligar anuncio cancelado
- Ingresar licencia válida y vigente
- Ingresar anuncio cancelado (vigente != 'V')
- Click en 'Ligar Anuncio'
- Esperar mensaje de error: 'No se puede ligar un anuncio cancelado.'

## Caso 3: Ligar anuncio ya ligado a otra licencia
- Ingresar licencia válida y vigente
- Ingresar anuncio con id_licencia > 0
- Click en 'Ligar Anuncio'
- Confirmar en el diálogo
- Esperar mensaje de éxito

## Caso 4: Ligar a empresa
- Seleccionar 'Buscar por Empresa'
- Ingresar empresa válida y vigente
- Ingresar anuncio válido y vigente
- Click en 'Ligar Anuncio'
- Esperar mensaje de éxito

## Caso 5: Error de datos insuficientes
- No ingresar licencia/empresa o anuncio
- Click en 'Ligar Anuncio'
- Esperar mensaje de error: 'Datos insuficientes'
