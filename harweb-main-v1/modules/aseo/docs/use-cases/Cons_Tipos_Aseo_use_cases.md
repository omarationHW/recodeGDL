# Casos de Uso - Cons_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta básica de Tipos de Aseo ordenados por Control

**Descripción:** El usuario accede a la página de consulta y visualiza todos los tipos de aseo ordenados por el campo 'Control'.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Consultas de Tipos de Aseo'.
2. El sistema muestra la tabla con los registros ordenados por 'Control'.

**Resultado esperado:**
Se muestran todos los registros de la tabla ta_16_tipo_aseo ordenados por ctrol_aseo.

**Datos de prueba:**
Tabla ta_16_tipo_aseo con al menos 3 registros distintos.

---

## Caso de Uso 2: Cambio de orden a 'Descripción'

**Descripción:** El usuario selecciona 'Descripción' en el selector de orden y la tabla se actualiza.

**Precondiciones:**
El usuario está en la página de consulta de Tipos de Aseo.

**Pasos a seguir:**
1. El usuario selecciona 'Descripción' en el combo de orden.
2. El sistema envía la petición con order='descripcion'.
3. El backend retorna los registros ordenados por descripción.

**Resultado esperado:**
La tabla se actualiza mostrando los registros ordenados alfabéticamente por descripción.

**Datos de prueba:**
Registros con descripciones: 'Hospitalario', 'Ordinario', 'Zona Centro'.

---

## Caso de Uso 3: Exportación a Excel

**Descripción:** El usuario hace clic en el botón 'Exportar Excel' y se genera un archivo descargable.

**Precondiciones:**
El usuario está en la página de consulta y hay registros en la tabla.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar Excel'.
2. El sistema genera el archivo Excel y lo descarga o muestra mensaje de éxito.

**Resultado esperado:**
El usuario recibe un archivo Excel con los datos actuales de la tabla.

**Datos de prueba:**
Registros actuales en la tabla ta_16_tipo_aseo.

---

