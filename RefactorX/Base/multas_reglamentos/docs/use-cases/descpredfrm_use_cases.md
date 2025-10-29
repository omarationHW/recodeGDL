# Casos de Uso - descpredfrm

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Predial

**Descripción:** Un usuario autorizado da de alta un nuevo descuento de predial para una cuenta específica.

**Precondiciones:**
El usuario tiene permisos y la cuenta no tiene un descuento vigente para el mismo periodo.

**Pasos a seguir:**
1. El usuario accede a la página de alta de descuento.
2. Llena los campos requeridos (cuenta, tipo, bimestres, solicitante, identificación, fecha de nacimiento, institución, porcentaje, observaciones).
3. Envía el formulario.
4. El frontend envía un eRequest con action 'create' a /api/execute.
5. El backend ejecuta el SP correspondiente y retorna el resultado.

**Resultado esperado:**
El descuento se crea correctamente y aparece en el listado como 'Vigente'.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "cvedescuento": 2,
  "bimini": 1,
  "bimfin": 6,
  "solicitante": "Juan Perez",
  "identificacion": "INE123456",
  "fecnac": "1980-05-10",
  "institucion": 1,
  "observaciones": "Descuento por adulto mayor",
  "porcentaje": 50
}

---

## Caso de Uso 2: Baja (Cancelación) de Descuento Predial

**Descripción:** Un usuario autorizado da de baja un descuento vigente, registrando el motivo.

**Precondiciones:**
El descuento está vigente y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de detalle del descuento.
2. Selecciona la opción 'Baja'.
3. Ingresa el motivo de la baja.
4. Confirma la acción.
5. El frontend envía un eRequest con action 'delete' a /api/execute.
6. El backend ejecuta el SP correspondiente y retorna el resultado.

**Resultado esperado:**
El descuento cambia a estado 'Cancelado' y se registra el motivo en observaciones.

**Datos de prueba:**
{
  "id": 1001,
  "motivo": "El beneficiario ya no cumple requisitos"
}

---

## Caso de Uso 3: Reactivación de Descuento Predial

**Descripción:** Un usuario autorizado reactiva un descuento previamente cancelado.

**Precondiciones:**
El descuento está en estado 'Cancelado' y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de detalle del descuento cancelado.
2. Selecciona la opción 'Reactivar'.
3. Confirma la acción.
4. El frontend envía un eRequest con action 'reactivate' a /api/execute.
5. El backend ejecuta el SP correspondiente y retorna el resultado.

**Resultado esperado:**
El descuento cambia a estado 'Vigente' y puede ser aplicado nuevamente.

**Datos de prueba:**
{
  "id": 1001
}

---

