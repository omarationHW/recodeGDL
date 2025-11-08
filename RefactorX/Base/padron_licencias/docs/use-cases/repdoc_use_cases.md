# Casos de Uso - repdoc

**Categoría:** Form

## Caso de Uso 1: Consulta de requisitos para un giro específico

**Descripción:** El usuario desea conocer los requisitos documentales para tramitar una licencia municipal para un giro determinado.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de requisitos documentales.

**Pasos a seguir:**
1. El usuario accede a la página de requisitos documentales.
2. Teclea parte de la actividad o selecciona el giro en el combo.
3. El sistema muestra el tipo y descripción del giro.
4. El sistema lista los requisitos asociados al giro.

**Resultado esperado:**
Se muestran correctamente los requisitos documentales para el giro seleccionado.

**Datos de prueba:**
Actividad: 'RESTAURANTE'; Giro: id_giro=1201

---

## Caso de Uso 2: Impresión de requisitos documentales

**Descripción:** El usuario necesita imprimir el listado de requisitos para un giro seleccionado.

**Precondiciones:**
El usuario ya seleccionó un giro y visualiza los requisitos.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Imprimir'.
2. El sistema genera una vista imprimible del reporte.
3. El usuario imprime o guarda como PDF.

**Resultado esperado:**
El reporte impreso contiene el encabezado, giro, tipo, actividad y todos los requisitos.

**Datos de prueba:**
Giro: id_giro=1302 (Ejemplo: 'BAR')

---

## Caso de Uso 3: Búsqueda de giros por actividad

**Descripción:** El usuario busca giros filtrando por texto de actividad.

**Precondiciones:**
El usuario está en la página de requisitos documentales.

**Pasos a seguir:**
1. El usuario escribe 'farmacia' en el campo de actividad.
2. El sistema filtra y muestra solo los giros que contienen 'farmacia' en la descripción.

**Resultado esperado:**
Solo se muestran giros relacionados con farmacias.

**Datos de prueba:**
Actividad: 'farmacia'

---

