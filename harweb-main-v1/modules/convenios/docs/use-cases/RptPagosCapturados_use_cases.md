# Casos de Uso - RptPagosCapturados

**Categoría:** Form

## Caso de Uso 1: Consulta de Pagos Capturados por Subtipo

**Descripción:** El usuario desea consultar todos los pagos capturados para el subtipo 'Predios Urbanos'.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados para el subtipo 1.

**Pasos a seguir:**
- Ingresar a la página 'Pagos Capturados'.
- Seleccionar 'Predios Urbanos' en el campo Subtipo.
- Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos capturados para el subtipo seleccionado, incluyendo detalles de manzana, lote, usuario, importes y claves.

**Datos de prueba:**
{ "subtipo": 1 }

---

## Caso de Uso 2: Validación de Parámetro Requerido

**Descripción:** El usuario intenta consultar pagos sin seleccionar un subtipo.

**Precondiciones:**
El usuario accede a la página y deja el campo subtipo vacío.

**Pasos a seguir:**
- Ingresar a la página 'Pagos Capturados'.
- No seleccionar ningún subtipo.
- Presionar el botón 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el parámetro subtipo es requerido.

**Datos de prueba:**
{ "subtipo": null }

---

## Caso de Uso 3: Consulta de Resumen de Pagos Capturados

**Descripción:** El usuario requiere un resumen de pagos capturados agrupados por manzana y lote para el subtipo 2.

**Precondiciones:**
El usuario tiene acceso y existen pagos para el subtipo 2.

**Pasos a seguir:**
- Enviar una petición a la API con acción 'getPagosCapturadosResumen' y subtipo 2.

**Resultado esperado:**
Se retorna una lista agrupada por manzana y lote con totales de pagos y recargos.

**Datos de prueba:**
{ "subtipo": 2 }

---

