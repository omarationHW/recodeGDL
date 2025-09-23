# Casos de Prueba: Consulta de Pagos de Energía

## Caso 1: Consulta por Local - Todos los campos llenos
- **Entrada:** oficina=1, num_mercado=2, categoria=1, seccion='A', local=10, letra_local=null, bloque=null
- **Acción:** Buscar
- **Resultado esperado:** Se muestran los pagos de energía del local 10, mercado 2, recaudadora 1, sección A, categoría 1.

## Caso 2: Consulta por Local - Solo oficina y mercado
- **Entrada:** oficina=1, num_mercado=2, categoria=null, seccion=null, local=null, letra_local=null, bloque=null
- **Acción:** Buscar
- **Resultado esperado:** Se muestran todos los pagos de energía de todos los locales del mercado 2, recaudadora 1.

## Caso 3: Consulta por Fecha de Pago - Todos los campos llenos
- **Entrada:** fecha_pago='2024-06-01', oficina_pago=1, caja_pago='A', operacion_pago=12345
- **Acción:** Buscar
- **Resultado esperado:** Se muestran los pagos de energía realizados el 2024-06-01 en la oficina 1, caja A, operación 12345.

## Caso 4: Consulta por Fecha de Pago - Solo fecha
- **Entrada:** fecha_pago='2024-06-01', oficina_pago=null, caja_pago=null, operacion_pago=null
- **Acción:** Buscar
- **Resultado esperado:** Se muestran todos los pagos de energía realizados el 2024-06-01.

## Caso 5: Listar recaudadoras
- **Acción:** Cargar página
- **Resultado esperado:** El combo de recaudadoras se llena con los datos de la tabla ta_12_recaudadoras.

## Caso 6: Listar secciones
- **Acción:** Cargar página
- **Resultado esperado:** El combo de secciones se llena con los datos de la tabla ta_11_secciones.

## Caso 7: Listar cajas por oficina
- **Entrada:** oficina=1
- **Acción:** Seleccionar oficina en filtro de fecha de pago
- **Resultado esperado:** El combo de cajas se llena con los datos de la tabla ta_12_operaciones para la oficina 1.

## Caso 8: Error de parámetros
- **Entrada:** Faltan parámetros requeridos
- **Acción:** Buscar
- **Resultado esperado:** Se muestra un mensaje de error en la respuesta eResponse.error
