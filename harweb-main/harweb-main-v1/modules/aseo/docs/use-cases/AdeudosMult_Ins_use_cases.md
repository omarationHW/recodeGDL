# Casos de Uso - AdeudosMult_Ins

**Categoría:** Form

## Caso de Uso 1: Carga masiva de excedentes para contratos vigentes

**Descripción:** El usuario desea cargar excedentes para varios contratos en un periodo específico, asegurando que no existan duplicados y que todos los contratos sean válidos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura. Los contratos existen y tienen cuota normal vigente para el periodo.

**Pasos a seguir:**
1. El usuario accede a la página de Generación Múltiple de Excedentes.
2. Selecciona el tipo de aseo, periodo (año y mes), tipo de movimiento y captura el oficio.
3. Llena la hoja de cálculo con varios contratos y cantidades de excedencia.
4. Presiona 'Validar' y verifica que no hay errores.
5. Presiona 'Grabar'.
6. El sistema procesa y muestra mensaje de éxito.

**Resultado esperado:**
Todos los excedentes se insertan correctamente. El usuario ve mensaje de éxito.

**Datos de prueba:**
tipoAseo: 9, tipoOper: 7, anio: 2024, mes: '06', oficio: 'OF-1234', rows: [{contrato: 12345, excedencia: 2}, {contrato: 23456, excedencia: 1}]

---

## Caso de Uso 2: Intento de carga con contrato inexistente

**Descripción:** El usuario intenta cargar un excedente para un contrato que no existe o no corresponde al tipo de aseo.

**Precondiciones:**
El usuario está autenticado. El contrato no existe o no corresponde al tipo de aseo.

**Pasos a seguir:**
1. El usuario accede a la página y llena los datos generales.
2. Ingresa un contrato inexistente en la hoja de cálculo.
3. Presiona 'Validar'.
4. El sistema muestra error en la fila correspondiente.

**Resultado esperado:**
El sistema no permite grabar y muestra el error específico.

**Datos de prueba:**
tipoAseo: 9, tipoOper: 7, anio: 2024, mes: '06', oficio: 'OF-1234', rows: [{contrato: 99999, excedencia: 1}]

---

## Caso de Uso 3: Carga con excedente ya existente para el periodo

**Descripción:** El usuario intenta cargar un excedente para un contrato y periodo donde ya existe un registro de excedente.

**Precondiciones:**
El usuario está autenticado. Ya existe un registro de excedente para ese contrato, periodo y tipo de operación.

**Pasos a seguir:**
1. El usuario accede a la página y llena los datos generales.
2. Ingresa un contrato y periodo donde ya existe excedente.
3. Presiona 'Validar'.
4. El sistema muestra error en la fila correspondiente.

**Resultado esperado:**
El sistema no permite grabar y muestra el error de duplicidad.

**Datos de prueba:**
tipoAseo: 9, tipoOper: 7, anio: 2024, mes: '06', oficio: 'OF-1234', rows: [{contrato: 12345, excedencia: 1}] (asumiendo que ya existe ese excedente)

---

