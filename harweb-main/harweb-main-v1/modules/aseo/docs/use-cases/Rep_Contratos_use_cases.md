# Casos de Uso - Rep_Contratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Reporte Empresa-Contratos para Todas las Empresas

**Descripción:** El usuario desea obtener un reporte de todas las empresas y sus contratos vigentes, ordenados por tipo de empresa y número de empresa.

**Precondiciones:**
El usuario tiene acceso al sistema y existen empresas y contratos vigentes en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Selecciona 'Todas las empresas' en el combo Empresa.
3. Selecciona 'Todos los tipos' en Tipo de Aseo.
4. Selecciona 'Vigentes' en Vigencia.
5. Selecciona 'Todas' en Recaudadora.
6. Selecciona 'Empresa - Contratos' como tipo de reporte.
7. Selecciona 'Tipo Emp, Num Emp' como orden.
8. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todas las empresas y sus contratos vigentes, agrupados y ordenados por tipo de empresa y número de empresa.

**Datos de prueba:**
Empresas: varias con contratos vigentes y cancelados. Contratos: con diferentes tipos de aseo y recaudadoras.

---

## Caso de Uso 2: Búsqueda de Contratos por Nombre de Empresa

**Descripción:** El usuario busca contratos de una empresa específica usando el buscador por nombre.

**Precondiciones:**
El usuario tiene acceso y conoce parte del nombre de la empresa.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Hace clic en 'Buscar por nombre'.
3. Escribe 'ALFA' en el campo de búsqueda y presiona Enter.
4. Selecciona la empresa 'ALFA S.A.' de la lista.
5. Selecciona 'Solo Contratos' como tipo de reporte.
6. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos de la empresa 'ALFA S.A.'.

**Datos de prueba:**
Empresa: 'ALFA S.A.' con varios contratos de diferentes tipos de aseo.

---

## Caso de Uso 3: Reporte de Contratos Filtrado por Tipo de Aseo y Recaudadora

**Descripción:** El usuario desea ver solo los contratos de tipo de aseo 'Hospitalario' y recaudadora 'Centro', sin importar la empresa.

**Precondiciones:**
Existen contratos con tipo de aseo 'Hospitalario' y recaudadora 'Centro'.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Selecciona 'Todos' en Empresa.
3. Selecciona 'Hospitalario' en Tipo de Aseo.
4. Selecciona 'Todos' en Vigencia.
5. Selecciona 'Centro' en Recaudadora.
6. Selecciona 'Solo Contratos' como tipo de reporte.
7. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos de tipo 'Hospitalario' y recaudadora 'Centro'.

**Datos de prueba:**
Contratos: varios con ctrol_aseo=4 (Hospitalario), id_rec=1 (Centro).

---

