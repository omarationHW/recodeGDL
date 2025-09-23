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
