# Casos de Uso - gruposLicenciasfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo grupo de licencias

**Descripción:** El usuario desea crear un nuevo grupo de licencias para organizar licencias relacionadas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para crear grupos.

**Pasos a seguir:**
1. El usuario ingresa a la página de Grupos de Licencias.
2. Hace clic en 'Agregar Grupo'.
3. Ingresa la descripción del grupo (ej: 'GRUPO COMERCIAL 2024').
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El grupo aparece en la lista de grupos con su nueva descripción.

**Datos de prueba:**
Descripción: 'GRUPO COMERCIAL 2024'

---

## Caso de Uso 2: Agregar licencias existentes a un grupo

**Descripción:** El usuario quiere asignar varias licencias vigentes a un grupo específico.

**Precondiciones:**
Existe al menos un grupo y varias licencias vigentes no asignadas a ese grupo.

**Pasos a seguir:**
1. El usuario selecciona un grupo de la lista.
2. Filtra licencias disponibles por giro o actividad si lo desea.
3. Selecciona varias licencias de la lista de disponibles.
4. Hace clic en 'Agregar al Grupo'.

**Resultado esperado:**
Las licencias seleccionadas desaparecen de la lista de disponibles y aparecen en la lista de licencias del grupo.

**Datos de prueba:**
Grupo: 'GRUPO COMERCIAL 2024', Licencias a agregar: [1001, 1002, 1003]

---

## Caso de Uso 3: Quitar licencias de un grupo

**Descripción:** El usuario necesita remover licencias de un grupo existente.

**Precondiciones:**
El grupo tiene licencias asignadas.

**Pasos a seguir:**
1. El usuario selecciona un grupo de la lista.
2. En la sección 'Licencias en el Grupo', selecciona una o más licencias.
3. Hace clic en 'Quitar del Grupo'.

**Resultado esperado:**
Las licencias seleccionadas desaparecen de la lista del grupo y vuelven a estar disponibles para asignación.

**Datos de prueba:**
Grupo: 'GRUPO COMERCIAL 2024', Licencias a quitar: [1002]

---

