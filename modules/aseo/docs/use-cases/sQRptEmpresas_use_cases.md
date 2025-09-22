# Casos de Uso - sQRptEmpresas

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de empresas ordenado por número de empresa

**Descripción:** El usuario accede a la página de reporte y selecciona la opción 'Número de Empresa' para visualizar el catálogo ordenado por este campo.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en las tablas ta_16_empresas y ta_16_tipos_emp.

**Pasos a seguir:**
1. Ingresar a la página 'Catálogo de Tipos de Empresas'.
2. Seleccionar 'Número de Empresa' en el selector de clasificación.
3. Esperar a que se cargue la tabla de resultados.

**Resultado esperado:**
La tabla muestra todas las empresas ordenadas por el campo 'num_empresa'.

**Datos de prueba:**
Empresas con num_empresa: 100, 101, 102, 103.

---

## Caso de Uso 2: Visualizar catálogo de empresas ordenado por tipo de empresa

**Descripción:** El usuario selecciona la opción 'Tipo de Empresa' para ver el catálogo agrupado y ordenado por tipo.

**Precondiciones:**
Existen al menos dos tipos de empresa y empresas asociadas a cada tipo.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Seleccionar 'Tipo de Empresa' en el selector.
3. Observar el ordenamiento de la tabla.

**Resultado esperado:**
Las empresas se agrupan y ordenan primero por tipo_empresa y luego por num_empresa.

**Datos de prueba:**
Tipos: 1 (Industrial), 2 (Comercial). Empresas: A (tipo 1), B (tipo 2), C (tipo 1).

---

## Caso de Uso 3: Visualizar catálogo de empresas ordenado por representante

**Descripción:** El usuario selecciona 'Representante' para ver el catálogo ordenado alfabéticamente por el nombre del representante.

**Precondiciones:**
Existen empresas con diferentes representantes.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Seleccionar 'Representante' en el selector.
3. Revisar el orden de la tabla.

**Resultado esperado:**
Las empresas aparecen ordenadas alfabéticamente por el campo 'representante'.

**Datos de prueba:**
Empresas: X (representante: Ana), Y (representante: Luis), Z (representante: Beatriz).

---

