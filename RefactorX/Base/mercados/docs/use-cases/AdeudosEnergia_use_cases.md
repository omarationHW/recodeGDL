# Casos de Uso - AdeudosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía por Año y Oficina

**Descripción:** El usuario desea consultar todos los adeudos de energía eléctrica del año 2024 para la oficina 5 (Cruz del Sur).

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
- Ingresa a la página de Adeudos de Energía.
- Selecciona el año 2024.
- Selecciona la oficina 5.
- Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los locales que tienen adeudos de energía eléctrica para el año y oficina seleccionados, incluyendo los periodos y cuotas.

**Datos de prueba:**
{ "axo": 2024, "oficina": 5 }

---

## Caso de Uso 2: Exportar Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos de energía a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
- Presiona el botón 'Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla.

**Datos de prueba:**
Datos de la consulta previa.

---

## Caso de Uso 3: Imprimir Reporte de Adeudos

**Descripción:** El usuario desea imprimir el reporte de adeudos de energía eléctrica.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
- Presiona el botón 'Imprimir'.

**Resultado esperado:**
Se genera y muestra un PDF listo para imprimir con el listado de adeudos.

**Datos de prueba:**
Datos de la consulta previa.

---

