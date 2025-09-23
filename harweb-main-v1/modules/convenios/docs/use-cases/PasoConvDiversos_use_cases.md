# Casos de Uso - PasoConvDiversos

**Categoría:** Form

## Caso de Uso 1: Carga y actualización masiva de convenios desde archivo plano

**Descripción:** El usuario carga un archivo plano con datos de convenios diversos y ejecuta la actualización masiva en la base de datos.

**Precondiciones:**
El usuario tiene permisos y el archivo está en formato pipe (|) con columnas correctas.

**Pasos a seguir:**
1. El usuario accede a la página PasoConvDiversos.
2. Selecciona el archivo plano y lo carga.
3. Visualiza la tabla previa con los datos parseados.
4. Presiona 'Actualizar Convenios'.
5. El sistema procesa cada fila: inserta o actualiza según corresponda.

**Resultado esperado:**
Todos los convenios del archivo quedan insertados o actualizados en la base de datos. Se muestra mensaje de éxito.

**Datos de prueba:**
Archivo plano con 5 filas, incluyendo casos nuevos y existentes.

---

## Caso de Uso 2: Validación de padron inexistente

**Descripción:** El sistema debe insertar en padron si no existe el registro antes de insertar el detalle.

**Precondiciones:**
El archivo contiene filas con combinaciones de tipo/subtipo/manzana/lote/letra que no existen en padron.

**Pasos a seguir:**
1. Cargar archivo con filas nuevas.
2. Procesar actualización.

**Resultado esperado:**
El sistema inserta primero en padron y luego en detalle, sin errores.

**Datos de prueba:**
Fila con tipo=14, subtipo=1, manzana='D66B1234', lote=5, letra='B' (no existe en padron).

---

## Caso de Uso 3: Actualización de convenio existente

**Descripción:** El sistema debe actualizar el detalle si ya existe el registro.

**Precondiciones:**
El archivo contiene filas que ya existen en padron y detalle.

**Pasos a seguir:**
1. Cargar archivo con filas existentes.
2. Procesar actualización.

**Resultado esperado:**
El sistema actualiza los campos del detalle correctamente.

**Datos de prueba:**
Fila con tipo=14, subtipo=1, manzana='D66B1234', lote=5, letra='B' (ya existe en padron y detalle).

---

