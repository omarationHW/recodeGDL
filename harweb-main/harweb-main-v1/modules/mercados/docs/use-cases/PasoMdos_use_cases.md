# Casos de Uso - PasoMdos

**Categoría:** Form

## Caso de Uso 1: Migrar todos los registros de Tianguis a Padron

**Descripción:** El usuario desea migrar todos los registros de la tabla cobrotrimestral al padrón de locales del Mercado de Abastos.

**Precondiciones:**
El usuario tiene permisos de administrador y la base de datos contiene registros en cobrotrimestral.

**Pasos a seguir:**
1. El usuario accede a la página PasoMdos.
2. Hace clic en 'Cargar Tianguis' y visualiza la tabla.
3. Hace clic en 'Migrar a Padron'.
4. El sistema ejecuta la migración y muestra el resultado.

**Resultado esperado:**
Todos los registros de Tianguis que no existían en el padrón son insertados. Se muestra el número de errores y existentes.

**Datos de prueba:**
cobrotrimestral: Folio=1001, Nombre='JUAN PEREZ', Domicilio='AV. CENTRAL', Superficie=10.5, Giro='ALIMENTOS', Descuento=0, MotivoDescuento=''

---

## Caso de Uso 2: Intentar migrar cuando todos los registros ya existen

**Descripción:** El usuario ejecuta la migración pero todos los folios ya existen en el padrón.

**Precondiciones:**
Todos los folios de cobrotrimestral ya existen en ta_11_locales.

**Pasos a seguir:**
1. El usuario accede a la página PasoMdos.
2. Hace clic en 'Cargar Tianguis'.
3. Hace clic en 'Migrar a Padron'.

**Resultado esperado:**
No se insertan nuevos registros. El resultado muestra existencias igual al total y errores igual a cero.

**Datos de prueba:**
cobrotrimestral: Folio=1001, ... (ya existe en ta_11_locales)

---

## Caso de Uso 3: Error de inserción por dato inválido

**Descripción:** Un registro de Tianguis tiene un valor inválido (por ejemplo, superficie negativa) y la inserción falla.

**Precondiciones:**
cobrotrimestral contiene un registro con Superficie=-5.

**Pasos a seguir:**
1. El usuario accede a la página PasoMdos.
2. Hace clic en 'Cargar Tianguis'.
3. Hace clic en 'Migrar a Padron'.

**Resultado esperado:**
El registro inválido no se inserta y aparece en la lista de errores con el mensaje correspondiente.

**Datos de prueba:**
cobrotrimestral: Folio=2002, Nombre='ERROR', Superficie=-5

---

