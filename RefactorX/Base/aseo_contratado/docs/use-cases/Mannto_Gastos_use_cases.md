# Casos de Uso - Mannto_Gastos

**Categoría:** Form

## Caso de Uso 1: Alta de Gastos

**Descripción:** El usuario administrador ingresa los parámetros de gastos para el ejercicio actual.

**Precondiciones:**
El usuario tiene permisos de administrador y no existe un registro previo en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Gastos.
2. Da clic en 'Nuevo Gasto'.
3. Llena los campos: Salario Diario ZMG, % Requerimiento, % Embargo, % Secuestro.
4. Da clic en 'Crear'.

**Resultado esperado:**
Se crea un registro en ta_16_gastos y se muestra en la tabla. Mensaje: 'Gastos creados correctamente.'

**Datos de prueba:**
{ "sdzmg": 150.00, "porc1_req": 10.5, "porc2_embargo": 15.0, "porc3_secuestro": 20.0 }

---

## Caso de Uso 2: Modificación de Gastos

**Descripción:** El usuario actualiza los parámetros de gastos existentes.

**Precondiciones:**
Existe un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Gastos.
2. Da clic en 'Editar' sobre el registro.
3. Modifica los valores requeridos.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
El registro es reemplazado por los nuevos valores. Mensaje: 'Gastos actualizados correctamente.'

**Datos de prueba:**
{ "sdzmg": 160.00, "porc1_req": 12.0, "porc2_embargo": 18.0, "porc3_secuestro": 22.0 }

---

## Caso de Uso 3: Eliminación de Gastos

**Descripción:** El usuario elimina todos los parámetros de gastos.

**Precondiciones:**
Existe al menos un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Gastos.
2. Da clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
No quedan registros en ta_16_gastos. Mensaje: 'Todos los gastos eliminados.'

**Datos de prueba:**
N/A

---

