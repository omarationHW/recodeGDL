# Casos de Uso - ColoniasMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva colonia

**Descripción:** Un usuario administrativo desea registrar una nueva colonia en el sistema.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario accede a la página de Colonias.
2. Da clic en 'Agregar', llena los campos: Colonia=123, Descripción='COLONIA NUEVA', Recaudadora=1, Zona=2, Col_Obra94=0.
3. Da clic en 'Agregar'.
4. El sistema valida y envía la petición a /api/execute con action 'colonias.create'.
5. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La colonia aparece en el listado y se muestra mensaje 'Colonia insertada correctamente'.

**Datos de prueba:**
{ "colonia": 123, "descripcion": "COLONIA NUEVA", "id_rec": 1, "id_zona": 2, "col_obra94": 0 }

---

## Caso de Uso 2: Edición de colonia existente

**Descripción:** Un usuario desea modificar la descripción y zona de una colonia existente.

**Precondiciones:**
La colonia 123 existe. El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario busca la colonia 123 en el listado.
2. Da clic en 'Editar'.
3. Cambia la descripción a 'COLONIA MODIFICADA' y la zona a 3.
4. Da clic en 'Actualizar'.
5. El sistema envía la petición a /api/execute con action 'colonias.update'.

**Resultado esperado:**
La colonia se actualiza y se muestra mensaje 'Colonia actualizada correctamente'.

**Datos de prueba:**
{ "colonia": 123, "descripcion": "COLONIA MODIFICADA", "id_rec": 1, "id_zona": 3, "col_obra94": 0 }

---

## Caso de Uso 3: Eliminación de colonia

**Descripción:** Un usuario desea eliminar una colonia que ya no es válida.

**Precondiciones:**
La colonia 123 existe y no tiene dependencias.

**Pasos a seguir:**
1. El usuario localiza la colonia 123 en el listado.
2. Da clic en 'Eliminar' y confirma.
3. El sistema envía la petición a /api/execute con action 'colonias.delete'.

**Resultado esperado:**
La colonia desaparece del listado y se muestra mensaje 'Colonia eliminada correctamente'.

**Datos de prueba:**
{ "colonia": 123 }

---

