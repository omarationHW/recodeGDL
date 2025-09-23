# Casos de Uso - ConsCapturaFecha

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos capturados por fecha y oficina

**Descripción:** El usuario desea ver todos los pagos capturados en una fecha específica, para una oficina y caja determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos Capturados.
2. Selecciona la fecha deseada.
3. Selecciona la oficina recaudadora.
4. Selecciona la caja correspondiente.
5. Ingresa el número de operación.
6. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos capturados que cumplen los criterios seleccionados.

**Datos de prueba:**
fecha: '2024-06-01', oficina: 2, caja: 'A', operacion: 12345

---

## Caso de Uso 2: Eliminación de un pago capturado y restauración de adeudo

**Descripción:** El usuario identifica un pago capturado erróneamente y decide eliminarlo, esperando que el adeudo se restaure automáticamente.

**Precondiciones:**
Existe al menos un pago capturado para los criterios seleccionados. El usuario tiene permisos de eliminación.

**Pasos a seguir:**
1. Realiza la consulta de pagos como en el caso anterior.
2. Selecciona el pago a eliminar marcando la casilla correspondiente.
3. Presiona 'Borrar Pago(s)'.
4. Confirma la eliminación.

**Resultado esperado:**
El pago es eliminado y el adeudo correspondiente se restaura en la base de datos.

**Datos de prueba:**
Pago con id_local: 1001, axo: 2024, periodo: 6

---

## Caso de Uso 3: Consulta de oficinas y cajas disponibles

**Descripción:** El usuario necesita seleccionar la oficina y caja antes de consultar pagos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos Capturados.
2. El sistema carga automáticamente la lista de oficinas.
3. Al seleccionar una oficina, el sistema carga las cajas disponibles para esa oficina.

**Resultado esperado:**
Las listas de oficinas y cajas se muestran correctamente y permiten la selección.

**Datos de prueba:**
oficina: 3 (espera ver cajas asociadas a la oficina 3)

---

