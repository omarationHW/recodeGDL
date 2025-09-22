# Casos de Uso - buscagirofrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda básica de giros por descripción

**Descripción:** El usuario busca giros comerciales que contengan la palabra 'papelería' en la descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página /buscagiro
2. Escribe 'papelería' en el campo de descripción
3. Presiona 'Buscar'
4. El sistema muestra la lista de giros que contienen 'papelería'

**Resultado esperado:**
Se muestra una tabla con los giros filtrados por la palabra 'papelería'.

**Datos de prueba:**
descripcion: 'papelería', tipo: 'L', autoev: false, pacto: false

---

## Caso de Uso 2: Filtrado de giros solo para autoevaluación

**Descripción:** El usuario requiere ver únicamente los giros disponibles para autoevaluación.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página /buscagiro
2. Marca la casilla 'Solo Autoevaluación'
3. Presiona 'Buscar'
4. El sistema muestra solo los giros permitidos para autoevaluación

**Resultado esperado:**
Se muestran únicamente los giros que están en el catálogo de autoevaluación.

**Datos de prueba:**
descripcion: '', tipo: 'L', autoev: true, pacto: false

---

## Caso de Uso 3: Selección de giro y obtención de detalles

**Descripción:** El usuario selecciona un giro de la lista para ver sus detalles completos.

**Precondiciones:**
El usuario ya realizó una búsqueda y hay resultados.

**Pasos a seguir:**
1. Realiza una búsqueda de giros
2. Da clic en 'Seleccionar' en uno de los resultados
3. El sistema muestra los detalles completos del giro seleccionado

**Resultado esperado:**
Se muestra un panel con los datos completos del giro seleccionado.

**Datos de prueba:**
id_giro: 1234

---

