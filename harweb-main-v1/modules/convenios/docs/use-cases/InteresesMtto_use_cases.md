# Casos de Uso - InteresesMtto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo interés de mantenimiento

**Descripción:** El usuario desea registrar el porcentaje de interés para el mes de julio de 2024.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce el año, mes y porcentaje.

**Pasos a seguir:**
1. Ingresa a la página de Intereses Mtto.
2. Da clic en 'Agregar'.
3. Llena los campos: Año=2024, Mes=7, Porcentaje=1.5, Usuario=5.
4. Da clic en 'Agregar'.

**Resultado esperado:**
El registro se agrega y aparece en el listado. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "mes": 7, "porcentaje": 1.5, "id_usuario": 5 }

---

## Caso de Uso 2: Modificación de un interés existente

**Descripción:** El usuario necesita corregir el porcentaje de interés para junio de 2024.

**Precondiciones:**
Existe un registro para año=2024, mes=6.

**Pasos a seguir:**
1. Busca el registro 2024-6 en el listado.
2. Da clic en 'Editar'.
3. Cambia el porcentaje a 1.75.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
El porcentaje se actualiza y se muestra mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "mes": 6, "porcentaje": 1.75, "id_usuario": 5 }

---

## Caso de Uso 3: Eliminación de un interés de mantenimiento

**Descripción:** El usuario elimina el registro de interés para mayo de 2024.

**Precondiciones:**
Existe un registro para año=2024, mes=5.

**Pasos a seguir:**
1. Busca el registro 2024-5 en el listado.
2. Da clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El registro desaparece del listado y se muestra mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "mes": 5 }

---

