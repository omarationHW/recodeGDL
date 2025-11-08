# Casos de Uso - sQRptContratos

**Categoría:** Form

## Caso de Uso 1: Consulta general de contratos vigentes

**Descripción:** El usuario desea obtener el listado completo de contratos vigentes, sin filtros adicionales.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos vigentes en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Deja todos los filtros en sus valores por defecto (seleccion=1, Vigencia='T').
3. Presiona el botón 'Generar Reporte'.

**Resultado esperado:**
Se muestra la tabla con todos los contratos vigentes y cancelados (excepto los de status 'Z'), junto con los totales.

**Datos de prueba:**
Base de datos con al menos 5 contratos vigentes y 2 cancelados.

---

## Caso de Uso 2: Reporte filtrado por empresa específica

**Descripción:** El usuario desea ver solo los contratos de una empresa específica.

**Precondiciones:**
El usuario conoce el número de empresa (Num_emp) y existen contratos asociados.

**Pasos a seguir:**
1. El usuario selecciona 'Por Empresa' en el filtro Selección.
2. Ingresa el número de empresa en el campo correspondiente.
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestran únicamente los contratos asociados a la empresa seleccionada.

**Datos de prueba:**
Num_emp=3, existen 2 contratos para esa empresa.

---

## Caso de Uso 3: Reporte de contratos cancelados por tipo de aseo

**Descripción:** El usuario desea ver todos los contratos cancelados de un tipo de aseo específico.

**Precondiciones:**
Existen contratos cancelados con Ctrol_Aseo=5.

**Pasos a seguir:**
1. El usuario selecciona Vigencia='C' (Cancelado).
2. Ingresa Ctrol_Aseo=5.
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestran solo los contratos cancelados con Ctrol_Aseo=5.

**Datos de prueba:**
Al menos 1 contrato cancelado con Ctrol_Aseo=5.

---

