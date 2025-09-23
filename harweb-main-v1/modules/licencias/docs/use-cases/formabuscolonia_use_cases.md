# Casos de Uso - formabuscolonia

**Categoría:** Form

## Caso de Uso 1: Búsqueda de colonias sin filtro

**Descripción:** El usuario accede a la página y visualiza todas las colonias del municipio 39 sin aplicar ningún filtro.

**Precondiciones:**
La tabla cp_correos contiene colonias para c_mnpio=39.

**Pasos a seguir:**
1. El usuario navega a la página de búsqueda de colonias.
2. No ingresa ningún texto en el campo de filtro.
3. El sistema muestra todas las colonias del municipio 39.

**Resultado esperado:**
Se listan todas las colonias disponibles para c_mnpio=39 en la tabla.

**Datos de prueba:**
cp_correos con al menos 3 colonias para c_mnpio=39.

---

## Caso de Uso 2: Filtrado de colonias por nombre parcial

**Descripción:** El usuario ingresa un texto parcial en el campo de filtro para buscar colonias cuyo nombre lo contenga.

**Precondiciones:**
La tabla cp_correos contiene colonias con nombres que incluyan el texto 'CENTRO' para c_mnpio=39.

**Pasos a seguir:**
1. El usuario navega a la página de búsqueda de colonias.
2. Ingresa 'CENTRO' en el campo de filtro.
3. El sistema filtra y muestra solo las colonias cuyo nombre contiene 'CENTRO'.

**Resultado esperado:**
Solo se muestran las colonias que contienen 'CENTRO' en su nombre.

**Datos de prueba:**
cp_correos con colonias 'CENTRO', 'CENTRO SUR', 'NORTE' para c_mnpio=39.

---

## Caso de Uso 3: Selección y confirmación de colonia

**Descripción:** El usuario selecciona una colonia de la lista y confirma su selección haciendo clic en 'Aceptar'.

**Precondiciones:**
La tabla cp_correos contiene la colonia 'CENTRO' para c_mnpio=39.

**Pasos a seguir:**
1. El usuario filtra por 'CENTRO'.
2. Selecciona la colonia 'CENTRO' de la tabla.
3. Hace clic en 'Aceptar'.
4. El sistema muestra los datos de la colonia seleccionada.

**Resultado esperado:**
Se muestra el nombre y código postal de la colonia 'CENTRO'.

**Datos de prueba:**
cp_correos con colonia 'CENTRO', d_codigopostal=12345, d_tipo_asenta='URBANO', c_mnpio=39.

---

