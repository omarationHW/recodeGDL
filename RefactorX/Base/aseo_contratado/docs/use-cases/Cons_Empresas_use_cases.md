# Casos de Uso - Cons_Empresas

**Categoría:** Form

## Caso de Uso 1: Consulta de empresa por número y tipo

**Descripción:** El usuario desea consultar una empresa específica ingresando su número y tipo.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número y tipo de la empresa.

**Pasos a seguir:**
1. Selecciona 'Por Número' en la opción de búsqueda.
2. Ingresa el número de empresa y selecciona el tipo de empresa.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la empresa correspondiente en la tabla con todos sus datos.

**Datos de prueba:**
{ "num_empresa": 123, "ctrol_emp": 9 }

---

## Caso de Uso 2: Búsqueda de empresas por nombre parcial

**Descripción:** El usuario busca todas las empresas cuyo nombre contiene una palabra clave.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Selecciona 'Por Nombre' en la opción de búsqueda.
2. Ingresa una palabra clave (ejemplo: 'ACME').
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se listan todas las empresas cuyo nombre contiene la palabra clave.

**Datos de prueba:**
{ "nombre": "ACME" }

---

## Caso de Uso 3: Exportar listado completo de empresas a Excel

**Descripción:** El usuario desea exportar el catálogo completo de empresas a un archivo Excel.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Selecciona 'Todas' en la opción de búsqueda.
2. Presiona el botón 'Buscar' para mostrar todas las empresas.
3. Presiona el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo CSV/Excel con todos los datos de empresas.

**Datos de prueba:**
{}

---

