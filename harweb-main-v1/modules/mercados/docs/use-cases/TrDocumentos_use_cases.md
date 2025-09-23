# Casos de Uso - TrDocumentos

**Categoría:** Form

## Caso de Uso 1: Consulta de Cheques por Fecha y Cuenta

**Descripción:** El usuario desea consultar todos los cheques emitidos en una fecha específica para una cuenta determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen cheques emitidos en la fecha y cuenta seleccionadas.

**Pasos a seguir:**
1. Ingresar a la página de Transferencia de Documentos.
2. Seleccionar la fecha de elaboración deseada.
3. Seleccionar la cuenta correspondiente.
4. Seleccionar 'Cheques' como tipo de documento.
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los cheques emitidos en la fecha y cuenta seleccionadas.

**Datos de prueba:**
fecha_elaboracion: '2024-06-01', cuenta: 1, tipo_doc: 'C'

---

## Caso de Uso 2: Generación de Archivo de Transferencia Electrónica (Bco. Pagador)

**Descripción:** El usuario genera el archivo de transferencia electrónica para pagos a través del banco pagador.

**Precondiciones:**
Existen documentos tipo 'Elec. Bco. Pagador' para la fecha y cuenta seleccionadas.

**Pasos a seguir:**
1. Seleccionar la fecha y cuenta.
2. Seleccionar 'Elec. Bco. Pagador' como tipo de documento.
3. Hacer clic en 'Buscar'.
4. Revisar la lista de documentos.
5. Hacer clic en 'Generar Archivo de Transferencia'.

**Resultado esperado:**
Se genera un archivo de texto descargable con los datos de transferencia electrónica.

**Datos de prueba:**
fecha_elaboracion: '2024-06-01', cuenta: 1, tipo_doc: 'P'

---

## Caso de Uso 3: Consulta de Transferencias a Otros Bancos

**Descripción:** El usuario consulta transferencias electrónicas realizadas a bancos distintos al pagador.

**Precondiciones:**
Existen transferencias electrónicas a otros bancos para la fecha y cuenta seleccionadas.

**Pasos a seguir:**
1. Seleccionar la fecha y cuenta.
2. Seleccionar 'Elec. Otros Bancos' como tipo de documento.
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con las transferencias electrónicas a otros bancos.

**Datos de prueba:**
fecha_elaboracion: '2024-06-01', cuenta: 1, tipo_doc: 'O'

---

