# Casos de Uso - MultipleRCM

**Categoría:** Form

## Caso de Uso 1: Búsqueda inicial de registros RCM por cementerio y clase

**Descripción:** El usuario desea consultar los primeros 100 registros de RCM del cementerio 'G', clase 1, sin filtros alfabéticos.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la base de datos.

**Pasos a seguir:**
- El usuario accede a la página 'Consulta Múltiple por RCM'.
- Selecciona el cementerio 'G'.
- Ingresa '1' en clase, deja los campos alfabéticos vacíos.
- Da clic en 'Buscar'.

**Resultado esperado:**
Se muestran hasta 100 registros que cumplen los criterios. Si hay más de 100, aparece el botón 'Continuar búsqueda'.

**Datos de prueba:**
{
  "cementerio": "G",
  "clase": 1,
  "clase_alfa": "",
  "seccion": 1,
  "seccion_alfa": "",
  "linea": 1,
  "linea_alfa": "",
  "fosa": 1,
  "fosa_alfa": "",
  "cuenta": 0
}

---

## Caso de Uso 2: Paginación de resultados (Continuar búsqueda)

**Descripción:** El usuario ya visualizó los primeros 100 registros y desea ver los siguientes.

**Precondiciones:**
El usuario realizó una búsqueda previa y hay más de 100 registros.

**Pasos a seguir:**
- El usuario da clic en 'Continuar búsqueda'.
- El sistema envía la misma consulta pero con 'cuenta' igual al último 'control_rcm' mostrado.

**Resultado esperado:**
Se muestran los siguientes 100 registros. El proceso puede repetirse hasta agotar los resultados.

**Datos de prueba:**
{
  "cementerio": "G",
  "clase": 1,
  "clase_alfa": "",
  "seccion": 1,
  "seccion_alfa": "",
  "linea": 1,
  "linea_alfa": "",
  "fosa": 1,
  "fosa_alfa": "",
  "cuenta": 12345 // último control_rcm mostrado
}

---

## Caso de Uso 3: Consulta de detalle de un registro RCM

**Descripción:** El usuario desea ver el detalle completo de un registro específico.

**Precondiciones:**
El usuario tiene una lista de resultados y selecciona un registro.

**Pasos a seguir:**
- El usuario da clic en 'Ver detalle' en la fila deseada.
- El sistema consulta el registro por su 'control_rcm'.

**Resultado esperado:**
Se muestra un modal con todos los campos del registro seleccionado.

**Datos de prueba:**
{
  "control_rcm": 12345
}

---

