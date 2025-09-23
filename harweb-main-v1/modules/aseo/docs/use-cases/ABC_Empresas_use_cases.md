# Casos de Uso - ABC_Empresas

**Categoría:** Form

## Caso de Uso 1: Alta de nueva empresa privada

**Descripción:** El usuario desea registrar una nueva empresa privada en el catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce el tipo de empresa.

**Pasos a seguir:**
1. El usuario accede a la página de Empresas.
2. Hace clic en 'Agregar Empresa'.
3. Selecciona 'Privada' en el combo de tipo de empresa.
4. Ingresa 'EMPRESA NUEVA' como descripción y 'JUAN PEREZ' como representante.
5. Hace clic en 'Guardar'.

**Resultado esperado:**
La empresa se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "ctrol_emp": 9, "descripcion": "EMPRESA NUEVA", "representante": "JUAN PEREZ" }

---

## Caso de Uso 2: Edición de empresa existente

**Descripción:** El usuario edita el nombre y representante de una empresa ya registrada.

**Precondiciones:**
Existe una empresa con num_empresa=5 y ctrol_emp=9.

**Pasos a seguir:**
1. El usuario busca la empresa con nombre 'EMPRESA VIEJA'.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'EMPRESA ACTUALIZADA' y el representante a 'MARIA LOPEZ'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La empresa se actualiza correctamente.

**Datos de prueba:**
{ "num_empresa": 5, "ctrol_emp": 9, "descripcion": "EMPRESA ACTUALIZADA", "representante": "MARIA LOPEZ" }

---

## Caso de Uso 3: Intento de eliminación de empresa con contratos asociados

**Descripción:** El usuario intenta eliminar una empresa que tiene contratos activos.

**Precondiciones:**
Existe una empresa con num_empresa=10, ctrol_emp=9 y al menos un contrato asociado.

**Pasos a seguir:**
1. El usuario busca la empresa con num_empresa=10.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se puede eliminar la empresa porque tiene contratos asociados.

**Datos de prueba:**
{ "num_empresa": 10, "ctrol_emp": 9 }

---

