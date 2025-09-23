# Casos de Uso - dependenciasFrm

**Categoría:** Form

## Caso de Uso 1: Agregar una inspección a un trámite

**Descripción:** El usuario desea agregar una revisión/inspección de una dependencia a un trámite específico.

**Precondiciones:**
El trámite existe y está en estado válido para agregar inspecciones. El usuario tiene permisos.

**Pasos a seguir:**
- El usuario accede a la página de revisiones del trámite.
- Selecciona una dependencia del catálogo desplegable.
- Presiona el botón 'Agregar'.
- El sistema valida que la inspección no exista ya.
- El sistema agrega la inspección y la muestra en la lista.

**Resultado esperado:**
La inspección aparece en la lista de inspecciones actuales del trámite.

**Datos de prueba:**
{ "id_tramite": 101, "id_dependencia": 22 }

---

## Caso de Uso 2: Eliminar una inspección de un trámite

**Descripción:** El usuario elimina una inspección previamente asignada a un trámite.

**Precondiciones:**
El trámite y la inspección existen. El usuario tiene permisos.

**Pasos a seguir:**
- El usuario visualiza la lista de inspecciones del trámite.
- Presiona el botón 'Eliminar' junto a la inspección deseada.
- El sistema solicita confirmación.
- El sistema elimina la inspección y la retira de la lista.

**Resultado esperado:**
La inspección ya no aparece en la lista de inspecciones del trámite.

**Datos de prueba:**
{ "id_tramite": 101, "id_dependencia": 22 }

---

## Caso de Uso 3: Visualizar inspecciones actuales de un trámite

**Descripción:** El usuario consulta las inspecciones asignadas actualmente a un trámite.

**Precondiciones:**
El trámite existe.

**Pasos a seguir:**
- El usuario accede a la página de revisiones del trámite.
- El sistema muestra la información básica del trámite y la lista de inspecciones actuales.

**Resultado esperado:**
Se muestra la lista de inspecciones actuales correctamente.

**Datos de prueba:**
{ "id_tramite": 101 }

---

