# Casos de Uso - Rep_Empresas

**Categoría:** Form

## Caso de Uso 1: Generar reporte de empresas ordenado por número

**Descripción:** El usuario desea obtener un listado de todas las empresas ordenadas por su número.

**Precondiciones:**
El usuario está autenticado y tiene permisos para ver reportes.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Empresas'.
2. Selecciona la opción 'Número' en el formulario.
3. Hace clic en 'Vista Previa'.
4. El sistema muestra la tabla con los datos ordenados por número de empresa.

**Resultado esperado:**
Se muestra una tabla con todas las empresas ordenadas por el campo 'num_empresa'.

**Datos de prueba:**
Empresas con num_empresa: 1, 2, 3, 4, 5.

---

## Caso de Uso 2: Generar reporte de empresas ordenado por tipo de empresa

**Descripción:** El usuario desea ver el reporte agrupado por tipo de empresa.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Selecciona 'Tipo de Empresa'.
3. Hace clic en 'Vista Previa'.

**Resultado esperado:**
La tabla muestra las empresas agrupadas y ordenadas por tipo_empresa.

**Datos de prueba:**
Empresas con tipos: 'Industrial', 'Comercial', 'Servicios'.

---

## Caso de Uso 3: Intentar generar reporte con parámetro inválido

**Descripción:** El usuario manipula el frontend y envía un parámetro de orden inválido.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario envía una petición con order=99.
2. El backend ejecuta el stored procedure.

**Resultado esperado:**
El backend retorna un error o una lista vacía, y el frontend muestra un mensaje de error.

**Datos de prueba:**
order=99

---

