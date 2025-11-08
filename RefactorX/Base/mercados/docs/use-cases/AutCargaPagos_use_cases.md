# Casos de Uso - AutCargaPagos

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva autorización de carga de pagos

**Descripción:** Un usuario con permisos administrativos necesita autorizar la carga de pagos para una oficina específica en una fecha determinada.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de administrador.

**Pasos a seguir:**
1. El usuario accede a la página 'Autorizar Carga de Pagos'.
2. Hace clic en 'Agregar'.
3. Completa el formulario con la fecha de ingreso, oficina, opción de autorizar, fecha límite, usuario permiso y comentarios.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la solicitud al backend.

**Resultado esperado:**
La nueva autorización aparece en la tabla y puede ser consultada o modificada.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-01",
  "oficina": 2,
  "autorizar": "S",
  "fecha_limite": "2024-06-10",
  "id_usupermiso": 5,
  "comentarios": "Autorización especial para cierre de mes."
}

---

## Caso de Uso 2: Modificar una autorización existente

**Descripción:** Un usuario necesita cambiar la fecha límite y los comentarios de una autorización ya registrada.

**Precondiciones:**
Debe existir al menos una autorización registrada.

**Pasos a seguir:**
1. El usuario selecciona una fila en la tabla de autorizaciones.
2. Hace clic en 'Modificar'.
3. Cambia la fecha límite y/o los comentarios.
4. Hace clic en 'Guardar'.
5. El sistema actualiza el registro.

**Resultado esperado:**
La autorización se actualiza y los cambios se reflejan en la tabla.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-01",
  "oficina": 2,
  "autorizar": "S",
  "fecha_limite": "2024-06-15",
  "id_usupermiso": 5,
  "comentarios": "Extensión de plazo por cierre fiscal."
}

---

## Caso de Uso 3: Consultar detalles y comentarios de una autorización

**Descripción:** Un usuario desea ver los comentarios y detalles de una autorización específica.

**Precondiciones:**
Debe haber al menos una autorización registrada.

**Pasos a seguir:**
1. El usuario selecciona una fila en la tabla.
2. El sistema muestra los comentarios y detalles en la sección inferior.

**Resultado esperado:**
Los comentarios y detalles se muestran correctamente.

**Datos de prueba:**
Seleccionar la autorización con fecha_ingreso = '2024-06-01' y oficina = 2.

---

