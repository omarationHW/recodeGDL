# Casos de Uso - UNIT9

**Categoría:** Form

## Caso de Uso 1: Visualizar la vista previa del reporte estándar

**Descripción:** El usuario accede a la página de vista previa y navega entre las páginas del reporte simulado.

**Precondiciones:**
El usuario tiene acceso a la aplicación y la tabla unit9_reports existe.

**Pasos a seguir:**
1. El usuario ingresa a la ruta /unit9-preview
2. El sistema carga la vista previa del reporte (3 páginas de ejemplo)
3. El usuario navega usando los botones de primera, anterior, siguiente y última página
4. El usuario ajusta el zoom usando los botones correspondientes

**Resultado esperado:**
El usuario puede ver las 3 páginas del reporte, navegar entre ellas y ajustar el zoom.

**Datos de prueba:**
No se requiere data específica (usa el SP de ejemplo).

---

## Caso de Uso 2: Guardar un reporte personalizado

**Descripción:** El usuario guarda el reporte actual bajo un nombre de archivo personalizado.

**Precondiciones:**
El usuario está en la vista previa y hay páginas cargadas.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Guardar reporte'
2. Ingresa el nombre 'reporte_test.json' en el modal
3. Confirma la acción
4. El sistema guarda el reporte en la tabla unit9_reports

**Resultado esperado:**
El reporte se guarda correctamente y puede ser cargado posteriormente.

**Datos de prueba:**
Nombre de archivo: reporte_test.json

---

## Caso de Uso 3: Cargar un reporte previamente guardado

**Descripción:** El usuario carga un reporte previamente guardado y visualiza su contenido.

**Precondiciones:**
Existe un registro en unit9_reports con file_name = 'reporte_test.json'.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Cargar reporte'
2. Ingresa el nombre 'reporte_test.json' en el modal
3. Confirma la acción
4. El sistema carga el reporte y lo muestra en la vista previa

**Resultado esperado:**
El reporte guardado se muestra correctamente en la vista previa.

**Datos de prueba:**
Nombre de archivo: reporte_test.json

---

