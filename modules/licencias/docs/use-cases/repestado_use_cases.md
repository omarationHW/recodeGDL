# Casos de Uso - repestado

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Trámite Existente

**Descripción:** El usuario consulta el estado de un trámite existente usando el número de trámite.

**Precondiciones:**
El trámite con id_tramite=12345 existe en la base de datos.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Reporte Estado del Trámite'.",
  "Ingresa el número 12345 en el campo 'No. Trámite'.",
  "Presiona el botón 'Buscar'.",
  "El sistema consulta el backend y muestra los datos del trámite."
]

**Resultado esperado:**
Se muestran todos los datos del trámite 12345, incluyendo solicitante, actividad, giro, dirección y estatus.

**Datos de prueba:**
{ "id_tramite": 12345 }

---

## Caso de Uso 2: Intento de Consulta de Trámite Inexistente

**Descripción:** El usuario intenta consultar un trámite que no existe.

**Precondiciones:**
No existe ningún trámite con id_tramite=999999.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Reporte Estado del Trámite'.",
  "Ingresa el número 999999 en el campo 'No. Trámite'.",
  "Presiona el botón 'Buscar'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se encontró el trámite.

**Datos de prueba:**
{ "id_tramite": 999999 }

---

## Caso de Uso 3: Impresión de Reporte de Estado de Trámite

**Descripción:** El usuario imprime el reporte del estado de un trámite existente.

**Precondiciones:**
El trámite con id_tramite=12345 existe.

**Pasos a seguir:**
[
  "El usuario consulta el trámite 12345 como en el primer caso de uso.",
  "Presiona el botón 'Imprimir Reporte'.",
  "El sistema genera el PDF y lo abre en una nueva ventana/pestaña."
]

**Resultado esperado:**
Se abre el PDF del reporte de estado del trámite 12345.

**Datos de prueba:**
{ "id_tramite": 12345 }

---

