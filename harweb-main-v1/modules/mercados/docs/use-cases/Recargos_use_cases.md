# Casos de Uso - Recargos

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo recargo

**Descripción:** El usuario desea registrar el porcentaje de recargo para el mes de julio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos de administración.

**Pasos a seguir:**
1. Ingresa a la página de Recargos.
2. Da clic en 'Agregar Recargo'.
3. Llena los campos: Año=2024, Mes=7, Porcentaje=2.5, Usuario=1.
4. Da clic en 'Guardar'.

**Resultado esperado:**
El nuevo recargo aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 2.5, "usuario_id": 1 }

---

## Caso de Uso 2: Modificación de un recargo existente

**Descripción:** El usuario necesita actualizar el porcentaje de recargo de julio 2024 a 3.0%.

**Precondiciones:**
Existe un recargo para 2024/7. El usuario tiene permisos.

**Pasos a seguir:**
1. Busca el recargo 2024/7 en la tabla.
2. Da clic en 'Editar'.
3. Cambia el porcentaje a 3.0.
4. Da clic en 'Guardar Cambios'.

**Resultado esperado:**
El porcentaje se actualiza y se refleja en la tabla.

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 3.0, "usuario_id": 1 }

---

## Caso de Uso 3: Eliminación de un recargo

**Descripción:** El usuario elimina el recargo del mes de junio 2023.

**Precondiciones:**
Existe un recargo para 2023/6.

**Pasos a seguir:**
1. Busca el recargo 2023/6 en la tabla.
2. Da clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El recargo desaparece de la tabla.

**Datos de prueba:**
{ "axo": 2023, "periodo": 6 }

---

