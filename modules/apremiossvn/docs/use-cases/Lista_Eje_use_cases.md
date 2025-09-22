# Casos de Uso - Lista_Eje

**Categoría:** Form

## Caso de Uso 1: Consulta de todos los ejecutores fiscales

**Descripción:** El usuario accede al catálogo de ejecutores y visualiza la lista completa (todos, sin filtro de vigencia).

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar el catálogo.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Ejecutores'.
2. Selecciona el filtro 'Todos'.
3. El sistema muestra la tabla con todos los ejecutores registrados.

**Resultado esperado:**
Se visualiza la lista completa de ejecutores, incluyendo los no vigentes.

**Datos de prueba:**
Base de datos con al menos 5 ejecutores, algunos con vigencia 'A' y otros con vigencia diferente.

---

## Caso de Uso 2: Filtrado de ejecutores vigentes

**Descripción:** El usuario filtra la lista para mostrar solo los ejecutores con vigencia activa.

**Precondiciones:**
El usuario está autenticado y en la página del catálogo.

**Pasos a seguir:**
1. El usuario selecciona el filtro 'Vigentes'.
2. El sistema filtra la tabla y muestra solo los ejecutores con vigencia 'A'.

**Resultado esperado:**
Solo se muestran ejecutores con vigencia igual a 'A'.

**Datos de prueba:**
Ejecutores con vigencia 'A' y otros con 'B' o 'C'.

---

## Caso de Uso 3: Exportación de la lista de ejecutores a Excel

**Descripción:** El usuario exporta la lista actual (filtrada o no) a un archivo Excel.

**Precondiciones:**
El usuario está autenticado y la lista está cargada.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Exportar a Excel'.
2. El sistema genera y descarga un archivo Excel con la lista mostrada.

**Resultado esperado:**
El archivo Excel contiene los datos visibles en la tabla.

**Datos de prueba:**
Lista filtrada por vigentes, exportación debe contener solo esos registros.

---

