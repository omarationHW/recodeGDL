# Casos de Uso - sQRptContratos_EstGral

**Categoría:** Form

## Caso de Uso 1: Visualización del reporte para un tipo de aseo específico

**Descripción:** El usuario accede a la página de Estadístico General de Contratos y selecciona un tipo de aseo para ver el reporte completo.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen datos en las tablas de contratos y pagos.

**Pasos a seguir:**
1. El usuario navega a la página 'Estadístico General de Contratos'.
2. El sistema carga y muestra la lista de tipos de aseo.
3. El usuario selecciona un tipo de aseo del combo.
4. El sistema consulta todos los SPs relacionados y muestra los datos en las tablas correspondientes.

**Resultado esperado:**
Se muestran correctamente los totales de contratos, cuotas normales, excedencias y contenedores, segmentados por estado.

**Datos de prueba:**
Tipo de aseo: ctrol_aseo=1 (ejemplo: 'DOMICILIARIO')

---

## Caso de Uso 2: Cambio de tipo de aseo y actualización de reporte

**Descripción:** El usuario cambia el tipo de aseo seleccionado y el reporte se actualiza automáticamente.

**Precondiciones:**
El usuario está en la página y ya visualizó un reporte.

**Pasos a seguir:**
1. El usuario selecciona otro tipo de aseo en el combo.
2. El sistema vuelve a consultar todos los SPs y actualiza los datos mostrados.

**Resultado esperado:**
Los datos del reporte cambian y corresponden al nuevo tipo de aseo seleccionado.

**Datos de prueba:**
Tipo de aseo: ctrol_aseo=2 (ejemplo: 'COMERCIAL')

---

## Caso de Uso 3: Manejo de error al ejecutar un SP inexistente

**Descripción:** El sistema maneja correctamente el error cuando se intenta ejecutar un SP que no existe.

**Precondiciones:**
El usuario o el frontend envía un nombre de SP incorrecto.

**Pasos a seguir:**
1. El frontend envía una petición con 'procedure': 'sp_inexistente'.
2. El backend intenta ejecutar el SP y falla.

**Resultado esperado:**
El sistema retorna un mensaje de error claro en eResponse indicando que el SP no existe.

**Datos de prueba:**
procedure: 'sp_inexistente', parameters: {}

---

