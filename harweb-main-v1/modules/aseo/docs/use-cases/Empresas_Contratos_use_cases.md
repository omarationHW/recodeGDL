# Casos de Uso - Empresas_Contratos

**Categoría:** Form

## Caso de Uso 1: Consulta general de todas las empresas y contratos

**Descripción:** El usuario desea ver la lista completa de todas las empresas y sus contratos, sin aplicar ningún filtro.

**Precondiciones:**
El usuario tiene acceso al sistema y existen empresas y contratos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Empresas y Contratos'.
2. Deja la opción en 'T = Todos'.
3. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todas las empresas y todos sus contratos, sin filtrar.

**Datos de prueba:**
parOpc: 'T', parDescrip: '', parTipo: 'T', parVigencia: 'T'

---

## Caso de Uso 2: Búsqueda por nombre de empresa vigente y tipo de aseo hospitalario

**Descripción:** El usuario busca empresas cuyo nombre contiene 'HOSPITAL', solo contratos vigentes y tipo de aseo hospitalario.

**Precondiciones:**
Existen empresas con nombre que contiene 'HOSPITAL' y contratos vigentes de tipo hospitalario.

**Pasos a seguir:**
1. Selecciona opción 'A = Búsqueda por Filtro'.
2. Escribe 'HOSPITAL' en 'Dato a Buscar'.
3. Selecciona 'H = Hospitalario' en tipo de aseo.
4. Selecciona 'V = VIGENTE' en vigencia.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestran solo las empresas y contratos que cumplen con los filtros indicados.

**Datos de prueba:**
parOpc: 'A', parDescrip: 'HOSPITAL', parTipo: 'H', parVigencia: 'V'

---

## Caso de Uso 3: Exportar resultados filtrados a Excel

**Descripción:** El usuario realiza una búsqueda filtrada y exporta los resultados a un archivo Excel (CSV).

**Precondiciones:**
Existen resultados para los filtros aplicados.

**Pasos a seguir:**
1. Realiza una búsqueda con filtros (por ejemplo, tipo de aseo 'O = Ordinario').
2. Da clic en 'Buscar'.
3. Da clic en 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo CSV con los resultados mostrados en la tabla.

**Datos de prueba:**
parOpc: 'T', parDescrip: '', parTipo: 'O', parVigencia: 'T'

---

