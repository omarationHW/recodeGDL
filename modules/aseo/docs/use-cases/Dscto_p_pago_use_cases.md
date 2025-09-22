# Casos de Uso - Dscto_p_pago

**Categoría:** Form

## Caso de Uso 1: Registrar un nuevo descuento por pronto pago

**Descripción:** El usuario desea registrar un nuevo periodo de descuento por pronto pago para incentivar el pago anticipado.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce las fechas y porcentaje de descuento.

**Pasos a seguir:**
1. Accede a la página de Descuentos por Pronto Pago.
2. Llena el formulario con fecha de inicio, fecha de fin, porcentaje de descuento y usuario.
3. Presiona 'Agregar'.
4. El sistema valida y registra el descuento.

**Resultado esperado:**
El nuevo descuento aparece en la tabla con status 'V'.

**Datos de prueba:**
{
  "fecha_inicio": "2024-07-01",
  "fecha_fin": "2024-07-31",
  "porc_dscto": 10.5,
  "usuario_mov": "admin"
}

---

## Caso de Uso 2: Cancelar un descuento vigente

**Descripción:** El usuario necesita cancelar un descuento vigente por error en las fechas.

**Precondiciones:**
Existe al menos un descuento con status 'V'.

**Pasos a seguir:**
1. Accede a la página de Descuentos por Pronto Pago.
2. Ubica el registro a cancelar en la tabla.
3. Presiona el botón 'Cancelar'.
4. Confirma la acción.

**Resultado esperado:**
El registro cambia su status a 'C' y no puede volver a ser cancelado.

**Datos de prueba:**
{
  "id": 1,
  "usuario_mov": "admin"
}

---

## Caso de Uso 3: Listar todos los descuentos

**Descripción:** El usuario desea consultar todos los periodos de descuento registrados.

**Precondiciones:**
Existen varios descuentos registrados.

**Pasos a seguir:**
1. Accede a la página de Descuentos por Pronto Pago.
2. Visualiza la tabla de registros.

**Resultado esperado:**
La tabla muestra todos los descuentos, tanto vigentes como cancelados.

**Datos de prueba:**
{}

---

