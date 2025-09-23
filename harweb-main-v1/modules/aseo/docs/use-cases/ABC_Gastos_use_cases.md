# Casos de Uso - ABC_Gastos

**Categoría:** Form

## Caso de Uso 1: Registrar nuevo catálogo de gastos

**Descripción:** El usuario desea registrar los parámetros de gastos para el año actual.

**Precondiciones:**
No existe ningún registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Gastos.
2. Llena los campos: Salario Diario, % Req., % Embargo, % Secuestro.
3. Presiona 'Crear'.
4. El sistema envía la petición 'gastos.create' al backend.

**Resultado esperado:**
El registro se crea correctamente y se muestra en la tabla de valores actuales.

**Datos de prueba:**
{ "sdzmg": 250.00, "porc1_req": 10.0, "porc2_embargo": 20.0, "porc3_secuestro": 30.0 }

---

## Caso de Uso 2: Actualizar el catálogo de gastos existente

**Descripción:** El usuario necesita modificar los porcentajes de embargo y secuestro.

**Precondiciones:**
Existe un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página y ve los valores actuales.
2. Modifica los campos % Embargo y % Secuestro.
3. Presiona 'Actualizar'.
4. El sistema envía la petición 'gastos.update' al backend.

**Resultado esperado:**
El registro se actualiza y los nuevos valores se muestran en la tabla.

**Datos de prueba:**
{ "sdzmg": 250.00, "porc1_req": 10.0, "porc2_embargo": 25.0, "porc3_secuestro": 35.0 }

---

## Caso de Uso 3: Eliminar el catálogo de gastos

**Descripción:** El usuario desea eliminar el registro de gastos para reiniciar el catálogo.

**Precondiciones:**
Existe un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página y presiona 'Eliminar'.
2. Confirma la acción.
3. El sistema envía la petición 'gastos.delete' al backend.

**Resultado esperado:**
El registro es eliminado y la tabla muestra 'Sin datos registrados'.

**Datos de prueba:**
No aplica

---

