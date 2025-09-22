# Casos de Uso - Contratos_Adeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos con adeudos vencidos

**Descripción:** El usuario desea obtener la lista de contratos con adeudos vencidos para el tipo de aseo Ordinario y vigencia Vigente.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar contratos.

**Pasos a seguir:**
1. El usuario accede a la página de Contratos con Adeudos.
2. Selecciona 'Ordinario' en Tipo de Aseo.
3. Selecciona 'Vigente' en Vigencia.
4. Selecciona 'Periodos Vencidos' en Tipo Reporte.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los contratos que cumplen los filtros, incluyendo todos los campos relevantes.

**Datos de prueba:**
parTipo: 'O', parVigencia: 'V', parReporte: 'V', pref: '2024-06'

---

## Caso de Uso 2: Consulta de contratos con adeudos en un periodo específico

**Descripción:** El usuario desea consultar contratos con adeudos para el periodo de marzo 2023, tipo de aseo Hospitalario y vigencia Conveniado.

**Precondiciones:**
El usuario tiene acceso y existen contratos con esos filtros.

**Pasos a seguir:**
1. Accede a la página.
2. Selecciona 'Hospitalario' en Tipo de Aseo.
3. Selecciona 'Conveniado' en Vigencia.
4. Selecciona 'Otro Periodo' en Tipo Reporte.
5. Ingresa '2023' en Año y '03' en Mes.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestran los contratos filtrados por periodo, tipo y vigencia.

**Datos de prueba:**
parTipo: 'H', parVigencia: 'N', parReporte: 'T', pref: '2023-03'

---

## Caso de Uso 3: Exportar resultados a Excel

**Descripción:** El usuario desea exportar la lista de contratos con adeudos a un archivo Excel.

**Precondiciones:**
El usuario ha realizado una búsqueda y hay resultados en pantalla.

**Pasos a seguir:**
1. Realiza una búsqueda con los filtros deseados.
2. Da clic en el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados.

**Datos de prueba:**
parTipo: 'C', parVigencia: 'T', parReporte: 'V', pref: '2024-06'

---

