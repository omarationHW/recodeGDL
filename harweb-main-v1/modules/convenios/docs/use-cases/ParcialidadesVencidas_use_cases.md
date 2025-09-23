# Casos de Uso - ParcialidadesVencidas

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenios con Parcialidades Vencidas

**Descripción:** El usuario desea visualizar todos los convenios que tienen parcialidades vencidas para su seguimiento y gestión.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar convenios.

**Pasos a seguir:**
1. El usuario accede a la página 'Parcialidades Vencidas'.
2. Da clic en el botón 'Buscar'.
3. El sistema consulta el backend y muestra la tabla con los convenios con parcialidades vencidas.

**Resultado esperado:**
Se muestra una tabla con los convenios, incluyendo nombre, domicilio, subtipo, fechas, adeudo, intereses, recargos y total.

**Datos de prueba:**
Base de datos con al menos 3 convenios con parcialidades vencidas y 2 sin vencidas.

---

## Caso de Uso 2: Exportación de Convenios Vencidos a Excel

**Descripción:** El usuario desea exportar la lista de convenios con parcialidades vencidas a un archivo Excel/CSV para análisis externo.

**Precondiciones:**
El usuario ha realizado una consulta y hay datos en la tabla.

**Pasos a seguir:**
1. El usuario accede a la página 'Parcialidades Vencidas'.
2. Da clic en el botón 'Buscar'.
3. Da clic en el botón 'Exportar Excel'.
4. El sistema descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene todos los registros y columnas mostradas en la tabla.

**Datos de prueba:**
Convenios con diferentes cantidades de parcialidades vencidas y montos variados.

---

## Caso de Uso 3: Manejo de Errores en la Consulta

**Descripción:** El usuario intenta consultar los convenios pero ocurre un error en el backend (por ejemplo, el stored procedure no existe).

**Precondiciones:**
El stored procedure está ausente o la base de datos está caída.

**Pasos a seguir:**
1. El usuario accede a la página 'Parcialidades Vencidas'.
2. Da clic en el botón 'Buscar'.
3. El backend retorna un error.

**Resultado esperado:**
Se muestra un mensaje de error claro al usuario indicando que no se pudo obtener la información.

**Datos de prueba:**
Simular caída de base de datos o renombrar el stored procedure temporalmente.

---

