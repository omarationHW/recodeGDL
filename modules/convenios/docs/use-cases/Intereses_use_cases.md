# Casos de Uso - Intereses

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo interés mensual

**Descripción:** El usuario desea registrar el porcentaje de interés para el mes de julio de 2024.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce el porcentaje a registrar.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Intereses.
2. Hace clic en 'Agregar Interés'.
3. Ingresa Año: 2024, Mes: 7, Porcentaje: 1.2500, ID Usuario: 5.
4. Confirma y guarda el registro.

**Resultado esperado:**
El nuevo registro aparece en la tabla con los datos ingresados y la fecha de actualización actual.

**Datos de prueba:**
{ axo: 2024, mes: 7, porcentaje: 1.25, id_usuario: 5 }

---

## Caso de Uso 2: Modificación de un interés existente

**Descripción:** El usuario necesita corregir el porcentaje de interés para junio de 2023.

**Precondiciones:**
Existe un registro para axo=2023, mes=6.

**Pasos a seguir:**
1. El usuario localiza el registro de 2023/6 en la tabla.
2. Hace clic en 'Editar'.
3. Cambia el porcentaje a 1.5000 y guarda.

**Resultado esperado:**
El registro se actualiza con el nuevo porcentaje y la fecha de actualización.

**Datos de prueba:**
{ axo: 2023, mes: 6, porcentaje: 1.5, id_usuario: 5 }

---

## Caso de Uso 3: Eliminación de un interés

**Descripción:** El usuario elimina un registro de interés para evitar duplicados.

**Precondiciones:**
Existe un registro para axo=2022, mes=12.

**Pasos a seguir:**
1. El usuario localiza el registro de 2022/12.
2. Hace clic en 'Eliminar' y confirma.

**Resultado esperado:**
El registro desaparece de la tabla y no puede ser consultado.

**Datos de prueba:**
{ axo: 2022, mes: 12 }

---

