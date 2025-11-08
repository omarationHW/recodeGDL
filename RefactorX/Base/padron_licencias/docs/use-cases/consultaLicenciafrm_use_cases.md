# Casos de Uso - consultaLicenciafrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencia por Número

**Descripción:** El usuario busca una licencia por su número y visualiza los detalles, pagos y adeudos.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
[
  "El usuario ingresa el número de licencia en el campo correspondiente.",
  "Presiona el botón 'Buscar'.",
  "El sistema consulta la API con operación 'search_by_licencia'.",
  "Se muestran los resultados en la tabla.",
  "El usuario selecciona una licencia y presiona 'Detalle'.",
  "El sistema muestra los detalles completos de la licencia.",
  "El usuario puede ver pagos y adeudos asociados."
]

**Resultado esperado:**
Se muestra la información completa de la licencia, incluyendo pagos y adeudos.

**Datos de prueba:**
{
  "licencia": "123456"
}

---

## Caso de Uso 2: Bloqueo y Desbloqueo de Licencia

**Descripción:** Un usuario con permisos bloquea y luego desbloquea una licencia.

**Precondiciones:**
El usuario tiene permisos de bloqueo/desbloqueo.

**Pasos a seguir:**
[
  "El usuario busca una licencia vigente.",
  "Presiona el botón 'Bloquear'.",
  "Ingresa el motivo del bloqueo.",
  "El sistema ejecuta el stored procedure de bloqueo.",
  "La licencia aparece como bloqueada.",
  "El usuario presiona 'Desbloquear'.",
  "Ingresa el motivo del desbloqueo.",
  "El sistema ejecuta el stored procedure de desbloqueo.",
  "La licencia aparece como no bloqueada."
]

**Resultado esperado:**
La licencia cambia de estado correctamente y se registran los motivos.

**Datos de prueba:**
{
  "id_licencia": 123456,
  "tipo_bloqueo": 1,
  "motivo": "Prueba de bloqueo"
}

---

## Caso de Uso 3: Exportación de Resultados a Excel

**Descripción:** El usuario exporta los resultados de una búsqueda a un archivo Excel.

**Precondiciones:**
El usuario tiene permisos de exportación.

**Pasos a seguir:**
[
  "El usuario realiza una búsqueda de licencias.",
  "Presiona el botón 'Exportar a Excel'.",
  "El sistema genera el archivo y devuelve una URL de descarga.",
  "El usuario descarga el archivo y lo abre en Excel."
]

**Resultado esperado:**
El archivo contiene los datos de la búsqueda en formato Excel.

**Datos de prueba:**
{
  "filtros": {
    "licencia": "",
    "ubicacion": "AV. JUAREZ",
    "propietario": "",
    "id_tramite": ""
  }
}

---

