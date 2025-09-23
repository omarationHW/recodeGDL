# Casos de Uso - PasoContratos

**Categoría:** Form

## Caso de Uso 1: Carga e Importación de Archivo de Contratos

**Descripción:** El usuario carga un archivo de texto con contratos y lo importa a la tabla de paso.

**Precondiciones:**
El usuario tiene acceso a la página PasoContratos y un archivo válido con datos separados por '|'.

**Pasos a seguir:**
1. El usuario accede a la página PasoContratos.
2. Hace click en 'Seleccionar archivo' y elige el archivo de contratos.
3. Visualiza la previsualización del archivo.
4. Hace click en 'Importar a BD'.
5. El sistema limpia la tabla de paso y almacena los registros.
6. El usuario ve el mensaje de éxito y el preview de la tabla de paso.

**Resultado esperado:**
Los contratos del archivo aparecen en la tabla de paso. El usuario ve mensaje de éxito.

**Datos de prueba:**
Archivo ejemplo:
1|101|201|0001|Juan Perez|Calle Falsa 123|12|A|10|20|200|Entre 1|Entre 2|1000|200|100|2023-01-01|ESCR|PROPIEDAD|COMDOM|OTROS|OBS|2023-01-02|2023-01-03|2023-01-04|1|0|0|0|MOTIVO|2023-01-05|2023-01-06|0|DOC|0|0|1|TODO

---

## Caso de Uso 2: Limpiar la Tabla de Paso antes de Importar

**Descripción:** El usuario limpia la tabla de paso antes de importar nuevos datos.

**Precondiciones:**
La tabla de paso contiene datos previos.

**Pasos a seguir:**
1. El usuario accede a la página PasoContratos.
2. Hace click en 'Limpiar Tabla Paso'.
3. El sistema ejecuta el SP de limpieza.
4. El usuario ve mensaje de éxito y la tabla de paso vacía.

**Resultado esperado:**
La tabla de paso queda vacía y lista para nueva importación.

**Datos de prueba:**
No aplica (operación sobre tabla existente).

---

## Caso de Uso 3: Visualizar Preview de Datos Cargados

**Descripción:** El usuario consulta el preview de los datos actualmente cargados en la tabla de paso.

**Precondiciones:**
La tabla de paso contiene datos.

**Pasos a seguir:**
1. El usuario accede a la página PasoContratos.
2. Hace click en 'Refrescar' en la sección de preview.
3. El sistema muestra los primeros 100 registros de la tabla de paso.

**Resultado esperado:**
El usuario visualiza los datos cargados en la tabla de paso.

**Datos de prueba:**
No aplica (operación de consulta).

---

