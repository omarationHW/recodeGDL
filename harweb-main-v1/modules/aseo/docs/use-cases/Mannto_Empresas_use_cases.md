# Casos de Uso - Mannto_Empresas

**Categoría:** Form

## Caso de Uso 1: Alta de Empresa Nueva

**Descripción:** El usuario desea registrar una nueva empresa privada en el sistema.

**Precondiciones:**
El usuario tiene permisos de alta. El tipo de empresa existe.

**Pasos a seguir:**
1. El usuario accede a la página de Empresas.
2. Selecciona el tipo de empresa (por ejemplo, 'Privada').
3. Ingresa el nombre/razón social y el representante.
4. Presiona 'Crear'.

**Resultado esperado:**
La empresa se registra correctamente, aparece en el listado y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "ctrol_emp": 9,
  "descripcion": "EMPRESA DE PRUEBA S.A. DE C.V.",
  "representante": "JUAN PEREZ"
}

---

## Caso de Uso 2: Modificación de Empresa Existente

**Descripción:** El usuario necesita actualizar el nombre y representante de una empresa existente.

**Precondiciones:**
La empresa existe y no está eliminada.

**Pasos a seguir:**
1. El usuario busca la empresa en el listado.
2. Presiona 'Editar'.
3. Modifica el nombre y/o representante.
4. Presiona 'Actualizar'.

**Resultado esperado:**
Los datos de la empresa se actualizan y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "num_empresa": 10,
  "ctrol_emp": 9,
  "descripcion": "EMPRESA MODIFICADA S.A. DE C.V.",
  "representante": "MARIA LOPEZ"
}

---

## Caso de Uso 3: Eliminación de Empresa sin Contratos

**Descripción:** El usuario desea eliminar una empresa que no tiene contratos asociados.

**Precondiciones:**
La empresa existe y no tiene contratos asociados.

**Pasos a seguir:**
1. El usuario localiza la empresa en el listado.
2. Presiona 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La empresa se elimina del sistema y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "num_empresa": 11,
  "ctrol_emp": 9
}

---

