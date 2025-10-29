# Casos de Uso - Requerimientos

**Categoría:** Form

## Caso de Uso 1: Búsqueda de Adeudos de Mercado

**Descripción:** El usuario busca adeudos de mercados filtrando por número de mercado y rango de adeudo.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar mercados.

**Pasos a seguir:**
[
  "El usuario accede a la página de Requerimientos.",
  "Selecciona 'Mercados' como aplicación.",
  "Elige un mercado del catálogo.",
  "Ingresa el rango de número de mercado y los importes de adeudo desde/hasta.",
  "Presiona 'Buscar'."
]

**Resultado esperado:**
Se muestra una tabla con los mercados y sus adeudos filtrados.

**Datos de prueba:**
{ "mercado": 1, "desde": 1, "hasta": 10, "adeudo_desde": 100, "adeudo_hasta": 1000 }

---

## Caso de Uso 2: Emisión de Requerimientos de Aseo

**Descripción:** El usuario emite requerimientos para contratos de aseo en un rango específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos para emitir requerimientos.

**Pasos a seguir:**
[
  "El usuario accede a la página de Requerimientos.",
  "Selecciona 'Aseo' como aplicación.",
  "Elige el tipo de aseo.",
  "Ingresa el rango de contratos y los importes de adeudo desde/hasta.",
  "Presiona 'Buscar' y luego 'Emitir Requerimientos'."
]

**Resultado esperado:**
Se generan los folios de requerimiento y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_aseo": "A", "desde": 100, "hasta": 200, "adeudo_desde": 500, "adeudo_hasta": 2000 }

---

## Caso de Uso 3: Validación de Error por Falta de Parámetros

**Descripción:** El usuario intenta buscar adeudos sin seleccionar un mercado.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
[
  "El usuario accede a la página de Requerimientos.",
  "Selecciona 'Mercados' como aplicación.",
  "No selecciona ningún mercado.",
  "Presiona 'Buscar'."
]

**Resultado esperado:**
Se muestra un mensaje de error indicando que el mercado es obligatorio.

**Datos de prueba:**
{ "mercado": "", "desde": 1, "hasta": 10, "adeudo_desde": 100, "adeudo_hasta": 1000 }

---

