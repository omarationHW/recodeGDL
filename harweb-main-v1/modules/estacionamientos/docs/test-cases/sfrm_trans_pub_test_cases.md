# Casos de Prueba para sfrm_trans_pub

## Caso 1: Carga e inserción de archivo válido
- **Entrada**: Archivo de texto con 10 líneas válidas (todas las posiciones correctas, fechas válidas)
- **Acción**: Cargar archivo, pasar datos, insertar registros
- **Esperado**: 10 registros insertados, mensaje de éxito

## Caso 2: Actualización de fechas de póliza
- **Entrada**: Archivo con 3 líneas, cada una con sector, categoría, número existentes y pol_fec diferente
- **Acción**: Cargar archivo, pasar datos, actualizar fechas
- **Esperado**: 3 registros actualizados, mensaje de éxito

## Caso 3: Archivo con líneas malformadas
- **Entrada**: Archivo con 5 líneas, 2 de ellas con menos de 155 caracteres
- **Acción**: Cargar archivo, pasar datos
- **Esperado**: Solo 3 líneas válidas mostradas en la tabla previa, mensaje de advertencia

## Caso 4: Archivo con fechas '00/00/00'
- **Entrada**: Archivo con líneas donde fec_alta, fec_inic, fec_venci o pol_fec son '00/00/00'
- **Acción**: Insertar registros
- **Esperado**: Los campos de fecha correspondientes se insertan como NULL en la base de datos

## Caso 5: Archivo con campos numéricos vacíos
- **Entrada**: Archivo con líneas donde cupo, delas, alas, subzona, clave están vacíos
- **Acción**: Insertar registros
- **Esperado**: Los campos numéricos vacíos se insertan como NULL

## Caso 6: Intento de insertar registros duplicados
- **Entrada**: Archivo con líneas que ya existen en la base de datos (mismo sector, categoría, número)
- **Acción**: Insertar registros
- **Esperado**: Los duplicados generan error o son ignorados según la política de la tabla. El mensaje debe reflejar el resultado.
