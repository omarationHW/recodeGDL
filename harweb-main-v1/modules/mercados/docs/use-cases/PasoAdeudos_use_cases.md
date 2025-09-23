# Casos de Uso - PasoAdeudos

**Categoría:** Form

## Caso de Uso 1: Generar y Previsualizar Adeudos para el Tianguis

**Descripción:** El usuario desea generar los adeudos del primer trimestre del año 2024 para todos los locales del tianguis.

**Precondiciones:**
El usuario tiene permisos de administrador y existen cuotas vigentes para 2024.

**Pasos a seguir:**
1. Acceder a la página Paso Adeudos.
2. Seleccionar trimestre 1 y año 2024.
3. Presionar 'Generar Adeudos'.

**Resultado esperado:**
Se muestra una tabla con los adeudos calculados para cada local del tianguis.

**Datos de prueba:**
trimestre: 1, ano: 2024

---

## Caso de Uso 2: Insertar Adeudos Generados

**Descripción:** El usuario, tras previsualizar los adeudos, decide insertarlos en la base de datos.

**Precondiciones:**
Se han generado los adeudos y no existen registros previos para ese año/trimestre.

**Pasos a seguir:**
1. Tras la previsualización, presionar 'Insertar Adeudos'.
2. Confirmar la operación si es necesario.

**Resultado esperado:**
Los adeudos se insertan correctamente en la base de datos y se muestra un mensaje de éxito.

**Datos de prueba:**
adeudos: [{id_local: 123, ano: 2024, periodo: 1, importe: 1234.56, ...}, ...]

---

## Caso de Uso 3: Intentar Insertar Adeudos Duplicados

**Descripción:** El usuario intenta insertar adeudos para un año/trimestre ya existente.

**Precondiciones:**
Ya existen adeudos para el año/trimestre seleccionado.

**Pasos a seguir:**
1. Generar e intentar insertar adeudos para el mismo año/trimestre dos veces.

**Resultado esperado:**
El sistema rechaza la segunda inserción y muestra un mensaje de error indicando duplicidad.

**Datos de prueba:**
adeudos: [{id_local: 123, ano: 2024, periodo: 1, importe: 1234.56, ...}, ...]

---

