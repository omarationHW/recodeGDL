# Casos de Uso - h_bloqueoDomiciliosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta general del histórico de domicilios bloqueados

**Descripción:** El usuario accede a la página de histórico y visualiza todos los domicilios bloqueados/desbloqueados ordenados por calle y número exterior.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
[
  "El usuario navega a la página 'Histórico de Bloqueo de Domicilios'.",
  "El sistema carga automáticamente la lista completa usando la acción 'listar' con orden 'calle,num_ext'.",
  "El usuario visualiza la tabla con todos los registros históricos."
]

**Resultado esperado:**
Se muestra la tabla con todos los domicilios históricos bloqueados/desbloqueados.

**Datos de prueba:**
No se requiere dato de entrada específico.

---

## Caso de Uso 2: Filtrado por calle específica

**Descripción:** El usuario busca domicilios históricos bloqueados que contengan una calle específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
[
  "El usuario escribe 'AVENIDA' en el campo de búsqueda.",
  "El sistema envía la acción 'filtrar' con campo 'calle' y valor 'AVENIDA'.",
  "La tabla se actualiza mostrando solo los registros que contienen 'AVENIDA' en el campo calle."
]

**Resultado esperado:**
Solo se muestran los domicilios históricos bloqueados cuya calle contiene 'AVENIDA'.

**Datos de prueba:**
Campo de búsqueda: 'AVENIDA'

---

## Caso de Uso 3: Exportación de listado a Excel

**Descripción:** El usuario exporta el listado actual de domicilios históricos bloqueados a un archivo Excel.

**Precondiciones:**
El usuario está autenticado y tiene permisos de exportación.

**Pasos a seguir:**
[
  "El usuario hace clic en el botón 'Exportar a Excel'.",
  "El sistema envía la acción 'exportar' con el orden actual.",
  "El frontend recibe los datos y genera un archivo Excel descargable.",
  "El usuario descarga el archivo Excel."
]

**Resultado esperado:**
El usuario obtiene un archivo Excel con el listado de domicilios históricos bloqueados.

**Datos de prueba:**
No se requiere dato de entrada específico.

---

