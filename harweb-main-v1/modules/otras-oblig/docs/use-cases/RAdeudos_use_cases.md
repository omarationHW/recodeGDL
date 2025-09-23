# Casos de Uso - RAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vencidos de un Local Existente

**Descripción:** El usuario ingresa el número y letra de un local existente y consulta los adeudos vencidos.

**Precondiciones:**
El local existe en la base de datos y tiene adeudos vencidos registrados.

**Pasos a seguir:**
1. Ingresar número de local (ej: 123).
2. Ingresar letra (ej: A).
3. Seleccionar 'Periodos Vencidos'.
4. Presionar 'Consultar'.

**Resultado esperado:**
Se muestran los datos del local y una tabla con los adeudos vencidos y totales.

**Datos de prueba:**
numero: 123, letra: A, vigencia: vencidos

---

## Caso de Uso 2: Consulta de Adeudos de Otro Periodo

**Descripción:** El usuario consulta los adeudos de un local para un año y mes específico.

**Precondiciones:**
El local existe y tiene adeudos para el periodo consultado.

**Pasos a seguir:**
1. Ingresar número de local (ej: 456).
2. Ingresar letra (ej: B).
3. Seleccionar 'Otro Periodo'.
4. Ingresar año (ej: 2023).
5. Seleccionar mes (ej: 05).
6. Presionar 'Consultar'.

**Resultado esperado:**
Se muestran los datos del local y los adeudos correspondientes al periodo seleccionado.

**Datos de prueba:**
numero: 456, letra: B, vigencia: otro, aso: 2023, mes: 05

---

## Caso de Uso 3: Intento de Consulta con Local Inexistente

**Descripción:** El usuario intenta consultar un local que no existe.

**Precondiciones:**
El número y letra ingresados no corresponden a ningún local en la base de datos.

**Pasos a seguir:**
1. Ingresar número de local (ej: 999).
2. Ingresar letra (ej: Z).
3. Seleccionar cualquier periodo.
4. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el local no existe.

**Datos de prueba:**
numero: 999, letra: Z, vigencia: vencidos

---

