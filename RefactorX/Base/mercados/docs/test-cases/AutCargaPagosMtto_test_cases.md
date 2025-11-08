# Casos de Prueba: AutCargaPagosMtto

## Caso 1: Registro exitoso de fecha autorizada
- **Precondición**: Usuario autenticado con permiso
- **Entrada**: fecha_ingreso=2024-06-05, oficina=2, autorizar='S', fecha_limite=2024-06-10, id_usupermiso=7, comentarios='AUTORIZADO POR AUDITORIA'
- **Acción**: POST /api/execute con action=insert_autcargapag
- **Resultado esperado**: Respuesta success=true, la fecha aparece en la lista

## Caso 2: Bloqueo de fecha existente
- **Precondición**: Fecha ya registrada como autorizada
- **Entrada**: fecha_ingreso=2024-06-05, oficina=2, autorizar='N', fecha_limite=2024-06-10, id_usupermiso=7, comentarios='BLOQUEADO POR SUPERVISIÓN'
- **Acción**: POST /api/execute con action=update_autcargapag
- **Resultado esperado**: Respuesta success=true, la fecha aparece como bloqueada

## Caso 3: Validación de campos obligatorios
- **Precondición**: Usuario autenticado
- **Entrada**: fecha_ingreso='', oficina=2, autorizar='S', fecha_limite='', id_usupermiso='', comentarios=''
- **Acción**: POST /api/execute con action=insert_autcargapag
- **Resultado esperado**: Respuesta success=false, message indica campos obligatorios

## Caso 4: Listado de fechas
- **Precondición**: Fechas registradas para la oficina
- **Entrada**: oficina=2
- **Acción**: POST /api/execute con action=list_autcargapag
- **Resultado esperado**: Respuesta success=true, data contiene arreglo de fechas

## Caso 5: Edición de comentario
- **Precondición**: Fecha existente
- **Entrada**: fecha_ingreso=2024-06-05, oficina=2, autorizar='S', fecha_limite=2024-06-10, id_usupermiso=7, comentarios='ACTUALIZADO POR ADMINISTRADOR'
- **Acción**: POST /api/execute con action=update_autcargapag
- **Resultado esperado**: Respuesta success=true, comentario actualizado en la lista
