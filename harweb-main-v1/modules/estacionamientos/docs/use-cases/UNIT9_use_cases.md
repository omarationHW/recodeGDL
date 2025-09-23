# Casos de Uso - UNIT9

**Categoría:** Form

## Caso de Uso 1: Navegación entre páginas de la vista previa

**Descripción:** El usuario navega entre las páginas del reporte usando los botones de navegación.

**Precondiciones:**
El usuario está autenticado y en la página de vista previa.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Primera página'.
2. El sistema muestra la primera página del reporte.
3. El usuario hace clic en 'Página siguiente'.
4. El sistema muestra la siguiente página.

**Resultado esperado:**
La vista previa se actualiza correctamente mostrando el contenido de la página correspondiente.

**Datos de prueba:**
No se requiere data específica; la simulación retorna contenido ficticio.

---

## Caso de Uso 2: Cargar vista previa desde archivo

**Descripción:** El usuario carga un reporte desde un archivo externo.

**Precondiciones:**
El usuario está en la página de vista previa.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Cargar desde archivo'.
2. Ingresa la ruta del archivo (ej: '/tmp/reporte1.rep').
3. El sistema muestra el contenido cargado desde el archivo.

**Resultado esperado:**
El sistema muestra el contenido simulado del archivo especificado.

**Datos de prueba:**
Ruta de archivo: '/tmp/reporte1.rep'

---

## Caso de Uso 3: Imprimir la vista previa

**Descripción:** El usuario envía la vista previa a impresión.

**Precondiciones:**
El usuario está en la página de vista previa.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Imprimir'.
2. El sistema simula el envío a impresión y muestra un mensaje de éxito.

**Resultado esperado:**
El sistema muestra un mensaje indicando que la impresión fue enviada.

**Datos de prueba:**
No se requiere data específica.

---

