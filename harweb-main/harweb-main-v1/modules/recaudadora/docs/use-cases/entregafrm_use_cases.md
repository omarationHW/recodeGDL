# Casos de Uso - entregafrm

**Categoría:** Form

## Caso de Uso 1: Asignación de requerimientos a ejecutor

**Descripción:** Un usuario administrativo busca un ejecutor y le asigna un requerimiento fiscal para una fecha y recaudadora específica.

**Precondiciones:**
El ejecutor existe y tiene capacidad para recibir requerimientos.

**Pasos a seguir:**
[
  "El usuario ingresa el número o nombre del ejecutor y realiza la búsqueda.",
  "Selecciona el ejecutor de la lista.",
  "Indica la recaudadora y la fecha de entrega.",
  "Visualiza los requerimientos disponibles.",
  "Selecciona un requerimiento y lo asigna.",
  "El sistema actualiza los contadores de asignados/pendientes."
]

**Resultado esperado:**
El requerimiento queda asignado al ejecutor y aparece en la lista de entregados.

**Datos de prueba:**
{
  "ejecutor": {
    "cveejecutor": 101,
    "nombre": "JUAN PEREZ"
  },
  "recaud": 1,
  "fecha": "2024-06-01",
  "folio": 5001
}

---

## Caso de Uso 2: Quitar requerimiento de ejecutor

**Descripción:** Un usuario necesita quitar la asignación de un requerimiento a un ejecutor por error.

**Precondiciones:**
El requerimiento está asignado y no ha sido practicado ni pagado.

**Pasos a seguir:**
[
  "El usuario busca el ejecutor y filtra los requerimientos asignados.",
  "Selecciona el requerimiento a quitar.",
  "Confirma la acción.",
  "El sistema desasigna el requerimiento y actualiza los contadores."
]

**Resultado esperado:**
El requerimiento ya no aparece como asignado al ejecutor.

**Datos de prueba:**
{
  "ejecutor": {
    "cveejecutor": 101
  },
  "recaud": 1,
  "folio": 5001
}

---

## Caso de Uso 3: Impresión de relación de entrega

**Descripción:** El usuario imprime la relación de entrega de requerimientos para un ejecutor en una fecha y recaudadora.

**Precondiciones:**
Existen requerimientos asignados al ejecutor en la fecha y recaudadora seleccionada.

**Pasos a seguir:**
[
  "El usuario busca y selecciona el ejecutor.",
  "Indica la recaudadora y la fecha.",
  "Solicita la impresión.",
  "El sistema devuelve los datos para impresión."
]

**Resultado esperado:**
Se genera un PDF o vista imprimible con la relación de entrega.

**Datos de prueba:**
{
  "ejecutor": {
    "cveejecutor": 101
  },
  "recaud": 1,
  "fecha": "2024-06-01"
}

---

