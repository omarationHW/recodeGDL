# Casos de Uso - sQRptTipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de tipos de aseo ordenado por Número de Control

**Descripción:** El usuario accede a la página de Tipos de Aseo y visualiza el catálogo ordenado por el campo 'Número de Control'.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_16_tipo_aseo.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Tipos de Aseo'.
2. Elige 'Número de Control' en el selector de clasificación.
3. El sistema consulta el API con opcion=1.
4. El sistema muestra la tabla ordenada por 'ctrol_aseo'.

**Resultado esperado:**
La tabla muestra todos los registros de tipos de aseo ordenados ascendentemente por el campo 'ctrol_aseo'.

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: '001', tipo_aseo: 'A', descripcion: 'Barrido'}, {ctrol_aseo: '002', tipo_aseo: 'B', descripcion: 'Recolección'}]

---

## Caso de Uso 2: Visualizar catálogo de tipos de aseo ordenado por Tipo

**Descripción:** El usuario selecciona la opción de clasificación por 'Tipo' y visualiza el catálogo ordenado por ese campo.

**Precondiciones:**
El usuario está en la página de Tipos de Aseo.

**Pasos a seguir:**
1. El usuario selecciona 'Tipo' en el selector de clasificación.
2. El sistema consulta el API con opcion=2.
3. El sistema muestra la tabla ordenada por 'tipo_aseo'.

**Resultado esperado:**
La tabla muestra los registros ordenados ascendentemente por el campo 'tipo_aseo'.

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: '002', tipo_aseo: 'B', descripcion: 'Recolección'}, {ctrol_aseo: '001', tipo_aseo: 'A', descripcion: 'Barrido'}]

---

## Caso de Uso 3: Visualizar catálogo de tipos de aseo ordenado por Descripción

**Descripción:** El usuario selecciona la opción de clasificación por 'Descripción' y visualiza el catálogo ordenado por ese campo.

**Precondiciones:**
El usuario está en la página de Tipos de Aseo.

**Pasos a seguir:**
1. El usuario selecciona 'Descripción' en el selector de clasificación.
2. El sistema consulta el API con opcion=3.
3. El sistema muestra la tabla ordenada por 'descripcion'.

**Resultado esperado:**
La tabla muestra los registros ordenados ascendentemente por el campo 'descripcion'.

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: '001', tipo_aseo: 'A', descripcion: 'Barrido'}, {ctrol_aseo: '002', tipo_aseo: 'B', descripcion: 'Recolección'}]

---

