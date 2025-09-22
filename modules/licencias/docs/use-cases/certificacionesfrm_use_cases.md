# Casos de Uso - certificacionesfrm

**Categoría:** Form

## Caso de Uso 1: Alta de Certificación de Licencia

**Descripción:** Un usuario de Padrón y Licencias requiere emitir una certificación para una licencia vigente.

**Precondiciones:**
El usuario está autenticado y conoce el ID de la licencia.

**Pasos a seguir:**
[
  "El usuario accede a la página de certificaciones.",
  "Hace clic en 'Nueva'.",
  "Selecciona 'Licencia' como tipo.",
  "Ingresa el ID de la licencia.",
  "Agrega una observación y la partida de pago si aplica.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
La certificación se crea, se asigna un folio único, y aparece en el listado.

**Datos de prueba:**
{
  "tipo": "L",
  "id_licencia": 12345,
  "observacion": "Certificación para trámite externo",
  "partidapago": "123456"
}

---

## Caso de Uso 2: Cancelación de Certificación

**Descripción:** Un usuario necesita cancelar una certificación emitida por error.

**Precondiciones:**
Existe una certificación vigente.

**Pasos a seguir:**
[
  "El usuario selecciona la certificación en el listado.",
  "Hace clic en 'Cancelar Certificación'.",
  "Ingresa el motivo de cancelación.",
  "Confirma la cancelación."
]

**Resultado esperado:**
La certificación cambia su estado a 'C' (cancelada) y el motivo queda registrado.

**Datos de prueba:**
{
  "id": 100,
  "motivo": "Error en datos del propietario"
}

---

## Caso de Uso 3: Búsqueda Avanzada de Certificaciones

**Descripción:** Un usuario requiere filtrar certificaciones por año, folio y tipo.

**Precondiciones:**
Existen certificaciones de varios años y tipos.

**Pasos a seguir:**
[
  "El usuario accede a la búsqueda avanzada.",
  "Ingresa el año (2024), folio (10), y selecciona tipo 'Anuncio'.",
  "Hace clic en 'Buscar'."
]

**Resultado esperado:**
Se muestran solo las certificaciones que cumplen con los filtros.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 10,
  "tipo": "A"
}

---

