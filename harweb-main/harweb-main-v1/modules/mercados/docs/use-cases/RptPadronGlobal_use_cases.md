# Casos de Uso - RptPadronGlobal

**Categoría:** Form

## Caso de Uso 1: Consulta del Padrón Global de Locales Vigentes

**Descripción:** El usuario desea consultar todos los locales vigentes al mes actual para identificar cuáles están al corriente y cuáles tienen adeudo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar el padrón.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes actual.
3. Selecciona 'Vigentes' en el campo Estatus.
4. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los locales vigentes, indicando nombre, superficie, renta calculada, estatus de adeudo y adicionales.

**Datos de prueba:**
{ "year": 2024, "month": 6, "status": "A" }

---

## Caso de Uso 2: Exportación a Excel del Padrón Global

**Descripción:** El usuario requiere exportar el padrón global de locales con estatus 'Todos' para análisis externo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de exportación.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes deseado.
3. Selecciona 'Todos' en el campo Estatus.
4. Presiona el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos del padrón global filtrados.

**Datos de prueba:**
{ "year": 2024, "month": 6, "status": "T" }

---

## Caso de Uso 3: Reporte PDF del Padrón Global de Locales con Adeudo

**Descripción:** El usuario necesita un reporte en PDF de todos los locales con adeudo para presentarlo a la dirección.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de reporte.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes deseado.
3. Selecciona 'Baja' en el campo Estatus.
4. Presiona el botón 'Reporte PDF'.

**Resultado esperado:**
Se genera y descarga un archivo PDF con los locales en baja y su estatus de adeudo.

**Datos de prueba:**
{ "year": 2024, "month": 6, "status": "B" }

---

