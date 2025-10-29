# Casos de Uso - CatRequisitos

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo requisito

**Descripción:** El usuario desea agregar un nuevo requisito al catálogo.

**Precondiciones:**
El usuario tiene acceso al módulo Catálogo de Requisitos.

**Pasos a seguir:**
- El usuario hace clic en 'Agregar'.
- Ingresa la descripción del requisito.
- Hace clic en 'Guardar'.
- El sistema envía un eRequest con action 'create'.
- El backend valida y agrega el requisito.

**Resultado esperado:**
El requisito aparece en el listado con un número asignado automáticamente.

**Datos de prueba:**
{ "descripcion": "Copia de comprobante de domicilio reciente" }

---

## Caso de Uso 2: Editar un requisito existente

**Descripción:** El usuario necesita corregir la descripción de un requisito.

**Precondiciones:**
Existe al menos un requisito en el catálogo.

**Pasos a seguir:**
- El usuario localiza el requisito y hace clic en 'Editar'.
- Modifica la descripción.
- Hace clic en 'Guardar'.
- El sistema envía un eRequest con action 'update'.

**Resultado esperado:**
La descripción del requisito se actualiza en el listado.

**Datos de prueba:**
{ "req": 3, "descripcion": "Copia de acta constitutiva actualizada" }

---

## Caso de Uso 3: Eliminar un requisito

**Descripción:** El usuario desea eliminar un requisito que ya no aplica.

**Precondiciones:**
El requisito existe y no está ligado a ningún proceso crítico.

**Pasos a seguir:**
- El usuario hace clic en 'Eliminar' junto al requisito.
- Confirma la eliminación.
- El sistema envía un eRequest con action 'delete'.

**Resultado esperado:**
El requisito desaparece del listado.

**Datos de prueba:**
{ "req": 5 }

---

