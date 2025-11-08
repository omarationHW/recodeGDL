# Casos de Uso - AutCargaPagosMtto

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva fecha de ingreso autorizada

**Descripción:** Un usuario con permiso desea autorizar una nueva fecha de ingreso para la carga de pagos de mantenimiento.

**Precondiciones:**
El usuario está autenticado y tiene permiso de autorización en su oficina.

**Pasos a seguir:**
1. El usuario accede a la página 'Autorizar Fecha de Ingreso'.
2. Selecciona la fecha de ingreso, la fecha límite y el usuario que otorga el permiso.
3. Escribe un comentario (opcional).
4. Da clic en 'Aceptar'.
5. El sistema valida y registra la fecha como autorizada.

**Resultado esperado:**
La fecha queda registrada y aparece en la lista de fechas autorizadas.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-05",
  "oficina": 2,
  "autorizar": "S",
  "fecha_limite": "2024-06-10",
  "id_usupermiso": 7,
  "comentarios": "AUTORIZADO POR AUDITORIA"
}

---

## Caso de Uso 2: Bloquear una fecha de ingreso

**Descripción:** Un usuario con permiso decide bloquear una fecha de ingreso previamente autorizada.

**Precondiciones:**
Existe una fecha de ingreso autorizada y el usuario tiene permiso.

**Pasos a seguir:**
1. El usuario accede a la página y localiza la fecha a bloquear.
2. Da clic en 'Editar'.
3. Cambia el campo 'Permiso' a 'BLOQUEAR FECHA'.
4. Actualiza el comentario.
5. Da clic en 'Aceptar'.

**Resultado esperado:**
La fecha queda marcada como bloqueada y no se permite la carga de pagos en esa fecha.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-05",
  "oficina": 2,
  "autorizar": "N",
  "fecha_limite": "2024-06-10",
  "id_usupermiso": 7,
  "comentarios": "BLOQUEADO POR SUPERVISIÓN"
}

---

## Caso de Uso 3: Listar fechas autorizadas y bloqueadas

**Descripción:** Un usuario consulta todas las fechas de ingreso autorizadas y bloqueadas para su oficina.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página.
2. El sistema muestra la tabla con todas las fechas y su estado (autorizada/bloqueada).

**Resultado esperado:**
Se visualizan correctamente todas las fechas con su estado y comentarios.

**Datos de prueba:**
{
  "oficina": 2
}

---

