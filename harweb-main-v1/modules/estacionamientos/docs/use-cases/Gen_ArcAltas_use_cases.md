# Casos de Uso - Gen_ArcAltas

**Categoría:** Form

## Caso de Uso 1: Generar archivo de altas para un nuevo periodo

**Descripción:** El usuario genera una remesa y descarga el archivo de texto correspondiente para un periodo de altas aún no procesado.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de altas en el periodo seleccionado.

**Pasos a seguir:**
1. Acceder a la página de Generación de Altas.
2. Verificar el último periodo mostrado.
3. Seleccionar fechas de inicio y fin para el nuevo periodo.
4. Hacer clic en 'Ejecutar'.
5. Esperar confirmación y visualizar el número de folios y remesa generada.
6. Hacer clic en 'Generar Archivo'.
7. Descargar el archivo generado.

**Resultado esperado:**
El archivo de texto se genera correctamente y contiene los folios de alta del periodo seleccionado.

**Datos de prueba:**
Periodo: 2024-06-01 a 2024-06-30. Existen 5 registros de alta en ese rango.

---

## Caso de Uso 2: Intentar generar archivo sin folios en el periodo

**Descripción:** El usuario intenta generar una remesa para un periodo donde no existen registros de alta.

**Precondiciones:**
El usuario tiene acceso al sistema. No existen registros de alta en el periodo seleccionado.

**Pasos a seguir:**
1. Acceder a la página de Generación de Altas.
2. Seleccionar un periodo sin registros (ej. 2023-01-01 a 2023-01-31).
3. Hacer clic en 'Ejecutar'.
4. Observar que el contador de folios es 0.
5. Intentar generar archivo.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay registros para generar el archivo.

**Datos de prueba:**
Periodo: 2023-01-01 a 2023-01-31. No existen registros de alta.

---

## Caso de Uso 3: Cancelar operación y reiniciar formulario

**Descripción:** El usuario cancela la operación y el formulario vuelve a su estado inicial.

**Precondiciones:**
El usuario ha iniciado el proceso de generación de remesa pero decide no continuar.

**Pasos a seguir:**
1. Acceder a la página de Generación de Altas.
2. Seleccionar un periodo y hacer clic en 'Ejecutar'.
3. Antes de generar el archivo, hacer clic en 'Cancelar'.

**Resultado esperado:**
El formulario se limpia y muestra nuevamente el último periodo registrado.

**Datos de prueba:**
Cualquier periodo válido.

---

