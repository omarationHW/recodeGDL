# 3 Ejemplos para probar el formulario entregafrm.vue

## Ejemplo 1: Entrega de Notificación de Predial

```json
{
  "tipo_entrega": "NOTIFICACION_PREDIAL",
  "folio": "NOT-2024-001",
  "ejecutor": "Juan Pérez García",
  "destinatario": "María González López",
  "domicilio": "AV. VALLARTA #1234, COL. AMERICANA",
  "clave_catastral": "58",
  "monto": 5000.00,
  "fecha_entrega": "2024-12-10",
  "hora_entrega": "14:30",
  "observaciones": "Recibió copia de notificación"
}
```

**Descripción:** Entrega de notificación de adeudo predial a contribuyente.

---

## Ejemplo 2: Entrega de Citatorio

```json
{
  "tipo_entrega": "CITATORIO",
  "folio": "CIT-2024-045",
  "ejecutor": "Roberto Martínez Hernández",
  "destinatario": "COMERCIALIZADORA DEL SOL S.A. DE C.V.",
  "domicilio": "CALLE JUAREZ #567, COL. CENTRO",
  "rfc": "CDS920101ABC",
  "motivo": "ADEUDO LICENCIA COMERCIAL",
  "monto": 12500.00,
  "fecha_entrega": "2024-12-10",
  "hora_entrega": "10:15",
  "observaciones": "Recibió representante legal con identificación"
}
```

**Descripción:** Entrega de citatorio a empresa por adeudo de licencia comercial.

---

## Ejemplo 3: Entrega de Requerimiento de Pago

```json
{
  "tipo_entrega": "REQUERIMIENTO_PAGO",
  "folio": "REQ-2024-078",
  "ejecutor": "Ana Patricia López Ruiz",
  "destinatario": "Carlos Ramírez Silva",
  "domicilio": "AV. PATRIA #890, COL. JARDINES DEL BOSQUE",
  "cuenta": "TRS-2024-002",
  "concepto": "DERECHOS DE TRANSITO",
  "monto": 3500.00,
  "fecha_entrega": "2024-12-10",
  "hora_entrega": "16:45",
  "plazo_pago": "15 días hábiles",
  "observaciones": "Se dejó copia con familiar mayor de edad"
}
```

**Descripción:** Entrega de requerimiento de pago por derechos de tránsito.

---

## Instrucciones de uso:

1. Ve al módulo **"Entrega"** en el sistema
2. Copia uno de los ejemplos JSON anteriores
3. Pégalo en el campo de texto "Datos (JSON)"
4. Presiona el botón **"Guardar"**
5. Observa el resultado en la tabla que aparece abajo

## Resultado esperado:

El sistema debería mostrar:
- **Estado:** Exitoso (verde) o Error (rojo)
- **Mensaje:** Confirmación del registro
- **Folio:** El folio de la entrega
- **Ejecutor:** Nombre del ejecutor
- **Fecha de Entrega:** Fecha registrada

---

## Notas:

- Los ejemplos incluyen diferentes tipos de entregas típicas de un sistema municipal
- Puedes modificar los valores según necesites
- El JSON debe ser válido (usar comillas dobles, sintaxis correcta)
- Todos los campos son opcionales según la lógica del SP
