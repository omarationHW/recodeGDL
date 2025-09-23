# Casos de Uso - DatosConvenio

**Categoría:** Form

## Caso de Uso 1: Visualización de datos generales de un convenio existente

**Descripción:** El usuario accede a la página de DatosConvenio para consultar la información general de un convenio específico.

**Precondiciones:**
El convenio con el identificador (control) existe en la base de datos y el usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario navega a la ruta de la página DatosConvenio con el parámetro 'control' correspondiente.
2. El frontend envía una petición POST a /api/execute con eRequest='getDatosConvenio' y el parámetro control.
3. El backend ejecuta el stored procedure y retorna los datos generales.
4. El frontend muestra los datos en el formulario de solo lectura.

**Resultado esperado:**
Se muestran correctamente todos los campos generales del convenio, incluyendo nombre, dirección, periodos, fechas y montos.

**Datos de prueba:**
{ "control": 123 }

---

## Caso de Uso 2: Consulta de parcialidades de un convenio

**Descripción:** El usuario revisa la tabla de parcialidades (adeudos parciales) asociadas a un convenio.

**Precondiciones:**
El convenio existe y tiene al menos una parcialidad registrada.

**Pasos a seguir:**
1. El usuario accede a la página DatosConvenio.
2. El frontend envía una petición POST a /api/execute con eRequest='getParcialidadesConvenio' y el parámetro control.
3. El backend ejecuta el stored procedure y retorna la lista de parcialidades.
4. El frontend muestra la tabla con las parcialidades y sus datos de pago.

**Resultado esperado:**
La tabla de parcialidades se muestra con todos los registros y columnas requeridas.

**Datos de prueba:**
{ "control": 123 }

---

## Caso de Uso 3: Consulta de pago de una parcialidad específica

**Descripción:** El usuario desea consultar el registro de pago de una parcialidad específica de un convenio.

**Precondiciones:**
El convenio y la parcialidad existen y tienen un pago registrado.

**Pasos a seguir:**
1. El usuario selecciona una parcialidad (por ejemplo, desde la tabla).
2. El frontend envía una petición POST a /api/execute con eRequest='getPagoParcialidad', control y parcial.
3. El backend ejecuta el stored procedure y retorna el registro de pago.
4. El frontend muestra los detalles del pago.

**Resultado esperado:**
Se muestran los datos del pago de la parcialidad seleccionada.

**Datos de prueba:**
{ "control": 123, "parcial": 2 }

---

