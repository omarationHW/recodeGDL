# Casos de Uso - PadronGlobal

**Categoría:** Form

## Caso de Uso 1: Consulta del Padrón Global de Locales Vigentes

**Descripción:** El usuario desea consultar todos los locales vigentes al mes y año actual.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de consulta.

**Pasos a seguir:**
1. Accede a la página 'Padrón Global de Locales'.
2. Selecciona el año y mes actual en los filtros.
3. Selecciona 'VIGENTES' como estado del local.
4. Haz clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con todos los locales vigentes, incluyendo cálculo de renta y leyenda de adeudo/corriente.

**Datos de prueba:**
{ "axo": 2024, "mes": 6, "vig": "A" }

---

## Caso de Uso 2: Exportación a Excel del Padrón Global de Locales con Baja

**Descripción:** El usuario requiere exportar a Excel el padrón de locales con baja total para un periodo específico.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de exportación.

**Pasos a seguir:**
1. Accede a la página 'Padrón Global de Locales'.
2. Selecciona el año 2023 y mes 12.
3. Selecciona 'CON BAJA TOTAL' como estado del local.
4. Haz clic en 'Consultar'.
5. Haz clic en 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos filtrados.

**Datos de prueba:**
{ "axo": 2023, "mes": 12, "vig": "B" }

---

## Caso de Uso 3: Visualización de Leyenda de Adeudo

**Descripción:** El usuario quiere identificar rápidamente qué locales tienen adeudo y cuáles están al corriente.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
1. Accede a la página 'Padrón Global de Locales'.
2. Selecciona cualquier año y mes.
3. Haz clic en 'Consultar'.
4. Observa la columna 'Leyenda' en la tabla.

**Resultado esperado:**
La columna 'Leyenda' muestra 'Local con Adeudo' o 'Local al Corriente de Pagos' según corresponda.

**Datos de prueba:**
{ "axo": 2024, "mes": 5, "vig": "A" }

---

