# Documentación Técnica: Cruces

## Análisis Técnico

# Documentación Técnica: Migración Formulario Cruces (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite seleccionar dos calles (cruce de calles) desde un catálogo, excluyendo aquellas marcadas como escondidas. El usuario puede buscar por nombre de calle en ambos campos, seleccionar una de cada lista y confirmar la selección. La lógica se ha migrado a una arquitectura moderna usando Laravel (API), Vue.js (frontend) y PostgreSQL (procedimientos almacenados).

## 2. Arquitectura
- **Frontend:** Vue.js (componente de página independiente, sin tabs)
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  - `eRequest`: Identificador de la operación (ej: `cruces_search_calle1`, `cruces_search_calle2`, `cruces_localiza_calle`)
  - `params`: Parámetros específicos de la operación
- **Response:**
  - `eResponse.success`: true/false
  - `eResponse.data`: Resultado de la operación
  - `eResponse.error`: Mensaje de error si aplica

## 4. Stored Procedures
- **sp_cruces_search_calle1(search_text TEXT):** Busca calles para el primer campo, excluyendo escondidas
- **sp_cruces_search_calle2(search_text TEXT):** Busca calles para el segundo campo, excluyendo escondidas
- **sp_cruces_localiza_calle(cvecalle1 INT, cvecalle2 INT):** Devuelve los datos completos de ambas calles seleccionadas

## 5. Flujo de la Interfaz
1. El usuario ingresa texto en el campo de búsqueda de la primera calle. Se consulta el API y se muestran resultados.
2. El usuario selecciona una calle de la lista.
3. El usuario repite el proceso para la segunda calle.
4. Al presionar "Aceptar", se consulta el API para obtener los datos completos de ambas calles seleccionadas.
5. El usuario puede cancelar para limpiar la selección.

## 6. Consideraciones Técnicas
- El filtrado es insensible a mayúsculas/minúsculas.
- Se excluyen las calles escondidas (`c_calles_escondidas` con `vigente='V'` y `num_tag=8000`).
- El endpoint es único y extensible para otros formularios.
- El frontend es una página Vue.js independiente, sin tabs ni dependencias de otros formularios.

## 7. Seguridad
- El endpoint debe protegerse con autenticación (no incluida aquí, pero recomendada en producción).
- Validar siempre los parámetros recibidos en el backend.

## 8. Extensibilidad
- Se pueden agregar más operaciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ser reutilizados por otros módulos.

## Casos de Prueba

# Casos de Prueba: Cruces

| Caso | Descripción | Entrada | Acción | Resultado Esperado |
|------|-------------|---------|--------|-------------------|
| TC01 | Búsqueda exitosa de dos calles | Calle1: 'INDE', Calle2: 'JUAR' | Buscar y seleccionar ambas, presionar 'Aceptar' | Se muestran los datos completos de ambas calles |
| TC02 | Búsqueda sin resultados | Calle1: 'ZZZZ', Calle2: 'XXXX' | Buscar en ambos campos | No se muestran resultados en las listas |
| TC03 | Selección de solo una calle | Calle1: 'INDE', Calle2: '' | Seleccionar solo una, presionar 'Aceptar' | Se muestra solo la información de la calle seleccionada, la otra como N/A |
| TC04 | Selección de ninguna calle | Calle1: '', Calle2: '' | Presionar 'Aceptar' | Se muestra mensaje de error: 'Debe seleccionar al menos una calle en cada lista.' |
| TC05 | Calle escondida | Calle1: nombre de una calle escondida | Buscar | No aparece en la lista de resultados |
| TC06 | Sensibilidad a mayúsculas/minúsculas | Calle1: 'independencia', Calle2: 'Juarez' | Buscar | Se muestran resultados correctamente |

## Casos de Uso

# Casos de Uso - Cruces

**Categoría:** Form

## Caso de Uso 1: Búsqueda y selección de dos calles para cruce

**Descripción:** El usuario busca y selecciona dos calles distintas para registrar un cruce.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles registradas en la base de datos.

**Pasos a seguir:**
[
  "El usuario ingresa parte del nombre de la primera calle en el campo de búsqueda.",
  "El sistema muestra una lista de coincidencias (excluyendo calles escondidas).",
  "El usuario selecciona una calle de la lista.",
  "El usuario ingresa parte del nombre de la segunda calle en el campo correspondiente.",
  "El sistema muestra una lista de coincidencias (excluyendo calles escondidas).",
  "El usuario selecciona una calle de la lista.",
  "El usuario presiona el botón 'Aceptar'.",
  "El sistema muestra los datos completos de ambas calles seleccionadas."
]

**Resultado esperado:**
Se muestran correctamente los datos de ambas calles seleccionadas.

**Datos de prueba:**
Calle1: 'INDEPENDENCIA', Calle2: 'JUAREZ'

---

## Caso de Uso 2: Búsqueda de calle inexistente

**Descripción:** El usuario intenta buscar una calle que no existe en el catálogo.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
[
  "El usuario ingresa un texto inexistente en el campo de búsqueda de la primera calle.",
  "El sistema consulta el API.",
  "El sistema muestra una lista vacía.",
  "El usuario repite el proceso en el campo de la segunda calle con otro texto inexistente.",
  "El sistema muestra una lista vacía."
]

**Resultado esperado:**
No se muestran resultados en la lista de búsqueda.

**Datos de prueba:**
Calle1: 'ZZZZZZ', Calle2: 'XXXXXX'

---

## Caso de Uso 3: Selección de solo una calle

**Descripción:** El usuario selecciona solo una calle y deja la otra sin seleccionar.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles registradas.

**Pasos a seguir:**
[
  "El usuario ingresa parte del nombre de la primera calle y selecciona una opción.",
  "El usuario deja el campo de la segunda calle vacío.",
  "El usuario presiona el botón 'Aceptar'.",
  "El sistema muestra los datos completos solo de la calle seleccionada."
]

**Resultado esperado:**
Se muestra correctamente la información de la calle seleccionada y la otra aparece como N/A.

**Datos de prueba:**
Calle1: 'INDEPENDENCIA', Calle2: ''

---
