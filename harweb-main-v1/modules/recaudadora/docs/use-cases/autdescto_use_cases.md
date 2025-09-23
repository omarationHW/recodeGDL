# Casos de Uso - autdescto

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Predial

**Descripción:** El usuario desea registrar un nuevo descuento de predial para una cuenta específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos para crear descuentos.

**Pasos a seguir:**
[
  "El usuario accede a la página de Autorización de Descuentos Predial.",
  "Llena el formulario con los datos requeridos (cuenta, tipo de descuento, bimestre inicial/final, solicitante, etc).",
  "Presiona el botón 'Guardar'.",
  "El sistema valida que no exista un descuento vigente para ese periodo.",
  "El sistema genera el folio y almacena el registro.",
  "El sistema muestra el nuevo descuento en la tabla."
]

**Resultado esperado:**
El descuento es creado y visible en la tabla de descuentos.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "cvedescuento": 1,
  "bimini": 1,
  "bimfin": 6,
  "solicitante": "Juan Perez",
  "observaciones": "Descuento por adulto mayor",
  "institucion": 2,
  "identificacion": "INE 123456",
  "fecnac": "1950-01-01"
}

---

## Caso de Uso 2: Cancelación de Descuento

**Descripción:** El usuario necesita cancelar un descuento vigente.

**Precondiciones:**
El descuento está vigente y el usuario tiene permisos.

**Pasos a seguir:**
[
  "El usuario localiza el descuento en la tabla.",
  "Presiona el botón 'Cancelar'.",
  "Confirma la acción.",
  "El sistema marca el descuento como cancelado, registra la fecha y usuario.",
  "El descuento aparece como 'Cancelado' en la tabla."
]

**Resultado esperado:**
El descuento queda cancelado y no puede ser editado.

**Datos de prueba:**
{
  "id": 101,
  "motivo": "Error en datos del solicitante"
}

---

## Caso de Uso 3: Reactivación de Descuento Cancelado

**Descripción:** El usuario requiere reactivar un descuento previamente cancelado.

**Precondiciones:**
El descuento está cancelado y el usuario tiene permisos.

**Pasos a seguir:**
[
  "El usuario localiza el descuento cancelado en la tabla.",
  "Presiona el botón 'Reactivar'.",
  "Confirma la acción.",
  "El sistema reactiva el descuento, borra la fecha de baja y usuario.",
  "El descuento aparece como 'Vigente' en la tabla."
]

**Resultado esperado:**
El descuento vuelve a estar vigente y editable.

**Datos de prueba:**
{
  "id": 101
}

---

