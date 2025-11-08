# Casos de Uso - RptAdeudosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía para un Año y Oficina

**Descripción:** El usuario desea obtener el listado de adeudos de energía eléctrica para todos los locales de una oficina y año específicos.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudo para el año y oficina seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Adeudos de Energía.
2. Selecciona el año (por ejemplo, 2023) y la oficina (por ejemplo, Zona Centro).
3. Presiona el botón 'Consultar'.
4. El sistema consulta el API y muestra el listado de adeudos.

**Resultado esperado:**
Se muestra una tabla con los datos de cada local, nombre, locales adicionales, meses y adeudo total. Se muestran los totales y el número de locales con adeudo.

**Datos de prueba:**
{ "axo": 2023, "oficina": 1 }

---

## Caso de Uso 2: Validación de Etiquetas según Año y Oficina

**Descripción:** El sistema debe mostrar las etiquetas correctas para 'Cuota Mes.' o 'Cuota Bim.' y 'Mes de Adeudo' o 'Bimestre de Adeudo' según el año y la oficina.

**Precondiciones:**
El usuario accede al reporte y selecciona diferentes combinaciones de año y oficina.

**Pasos a seguir:**
1. Seleccionar oficina distinta de 5 y año mayor a 2002.
2. Consultar el reporte y verificar que las etiquetas sean 'Cuota Mes.' y 'Mes de Adeudo'.
3. Seleccionar año menor o igual a 2002 y consultar, verificar que las etiquetas cambian a 'Cuota Bim.' y 'Bimestre de Adeudo'.
4. Seleccionar oficina 5 y consultar, verificar que la columna de cuota no se muestra.

**Resultado esperado:**
Las etiquetas y columnas se ajustan dinámicamente según la lógica de negocio.

**Datos de prueba:**
{ "axo": 2001, "oficina": 2 } y { "axo": 2024, "oficina": 5 }

---

## Caso de Uso 3: Manejo de Errores por Parámetros Faltantes

**Descripción:** El sistema debe manejar adecuadamente los casos en que el usuario no proporciona los parámetros requeridos.

**Precondiciones:**
El usuario intenta consultar el reporte sin seleccionar año u oficina.

**Pasos a seguir:**
1. Dejar vacío el campo año o la oficina.
2. Presionar 'Consultar'.
3. El sistema debe mostrar un mensaje de error indicando los parámetros faltantes.

**Resultado esperado:**
El usuario recibe un mensaje claro de error y no se realiza la consulta.

**Datos de prueba:**
{ "axo": null, "oficina": 1 }

---

