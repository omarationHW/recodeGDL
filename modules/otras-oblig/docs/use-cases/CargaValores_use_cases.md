# Casos de Uso - CargaValores

**Categoría:** Form

## Caso de Uso 1: Carga de valores para una tabla existente

**Descripción:** El usuario selecciona una tabla, ingresa valores para varias unidades y aplica la carga.

**Precondiciones:**
El usuario tiene acceso al sistema y existen tablas configuradas.

**Pasos a seguir:**
1. Ingresar a la página de Carga de Valores.
2. Seleccionar una tabla del listado.
3. Ingresar los datos requeridos en una o más filas (Ejercicio, Cve Und, Cve Oper, Descripción, $ Costo).
4. Hacer clic en 'Aplicar'.

**Resultado esperado:**
Los valores se insertan correctamente en la base de datos y se muestra un mensaje de éxito.

**Datos de prueba:**
[{"ejercicio":2024, "cve_unidad":"A", "cve_operatividad":"X", "descripcion":"Unidad X", "costo":100.50}]

---

## Caso de Uso 2: Intento de carga con filas incompletas

**Descripción:** El usuario intenta aplicar la carga dejando filas vacías o con datos incompletos.

**Precondiciones:**
El usuario está en la página de Carga de Valores.

**Pasos a seguir:**
1. Seleccionar una tabla.
2. Dejar una o más filas con campos vacíos o costo en cero.
3. Hacer clic en 'Aplicar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe capturar al menos un valor válido.

**Datos de prueba:**
[{"ejercicio":2024, "cve_unidad":"", "cve_operatividad":"", "descripcion":"", "costo":0}]

---

## Caso de Uso 3: Carga masiva de valores

**Descripción:** El usuario agrega varias filas y realiza una carga masiva de valores.

**Precondiciones:**
El usuario tiene permisos y la tabla seleccionada permite múltiples registros.

**Pasos a seguir:**
1. Seleccionar una tabla.
2. Agregar varias filas con datos válidos.
3. Hacer clic en 'Aplicar'.

**Resultado esperado:**
Todos los valores válidos se insertan correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
[{"ejercicio":2024, "cve_unidad":"A", "cve_operatividad":"X", "descripcion":"Unidad X", "costo":100.50}, {"ejercicio":2024, "cve_unidad":"B", "cve_operatividad":"Y", "descripcion":"Unidad Y", "costo":200.00}]

---

