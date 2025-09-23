# Casos de Uso - EdoCuenta

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta por Tipo y Subtipo

**Descripción:** El usuario consulta el estado de cuenta de convenios de regularización de predios para un tipo y subtipo específico.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la base de datos para el tipo y subtipo seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página EdoCuenta.
2. Selecciona 'Tipo' y 'Subtipo' en los combos.
3. Presiona 'Consultar Estado de Cuenta'.
4. El sistema envía la petición a /api/execute con action 'list'.
5. El backend retorna el listado de convenios y adeudos.

**Resultado esperado:**
Se muestra una tabla con los convenios, adeudos, pagos y recargos correspondientes.

**Datos de prueba:**
{ tipo: 1, subtipo: 1 }

---

## Caso de Uso 2: Impresión de Estado de Cuenta Detallado

**Descripción:** El usuario imprime el reporte detallado del estado de cuenta para un tipo y subtipo.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos disponibles.

**Pasos a seguir:**
1. El usuario presiona el botón 'Imprimir Estado de Cuenta'.
2. El sistema envía la petición a /api/execute con action 'report'.
3. El backend retorna los datos detallados para impresión.

**Resultado esperado:**
Se genera un PDF o vista imprimible con el detalle de pagos y recargos.

**Datos de prueba:**
{ tipo: 1, subtipo: 1 }

---

## Caso de Uso 3: Cálculo de Recargos para una Parcialidad

**Descripción:** El sistema calcula los recargos para un adeudo específico considerando días inhábiles y vencimientos.

**Precondiciones:**
Existe un adeudo con id_conv_resto y pago_parcial válido.

**Pasos a seguir:**
1. El usuario solicita el cálculo de recargos para un adeudo.
2. El sistema envía la petición a /api/execute con action 'recargos'.
3. El backend ejecuta el SP y retorna el monto de recargos.

**Resultado esperado:**
Se muestra el monto de recargos calculado correctamente.

**Datos de prueba:**
{ id_conv_resto: 123, pago_parcial: 1 }

---

