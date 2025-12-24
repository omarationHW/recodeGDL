# Documentación: trasladosfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario trasladosfrm

## 1. Descripción General
Este módulo permite la gestión de traslados de pagos erróneos, permitiendo buscar pagos, visualizar requerimientos asociados, aplicar traslados (a futuros pagos, saldar adeudos o devolución) y liquidar pagos. La migración se realizó desde Delphi a una arquitectura Laravel + Vue.js + PostgreSQL.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "buscar_pago|obtener_requerimientos|aplicar_traslado|liquidar_pago",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures
- **buscar_pago:** Busca pagos por recaud, folio, caja, fecha e importe.
- **obtener_requerimientos:** Lista requerimientos asociados a un pago.
- **aplicar_traslado:** Aplica el traslado según tipo (futuros, saldar, devolución).
- **liquidar_pago:** Marca el pago como liquidado.

## 5. Flujo de la Interfaz
1. El usuario ingresa los datos del pago erróneo y busca el pago.
2. Si se encuentra, se muestran los detalles y requerimientos asociados.
3. El usuario selecciona el tipo de aplicación y aplica el traslado.
4. Puede liquidar el pago si es necesario.

## 6. Seguridad
- Validación de parámetros en backend.
- Solo acciones permitidas por el endpoint.

## 7. Consideraciones
- El componente Vue es una página independiente, sin tabs.
- Navegación por breadcrumbs.
- Toda la lógica de negocio reside en stored procedures.

## 8. Extensibilidad
- Para agregar nuevas acciones, crear un nuevo stored procedure y mapearlo en el controlador.

## Casos de Uso

# Casos de Uso - trasladosfrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de un pago existente

**Descripción:** El usuario ingresa los datos de un pago y verifica si existe en el sistema.

**Precondiciones:**
El pago debe existir en la tabla pagos con los datos correctos.

**Pasos a seguir:**
1. Ingresar recaud, folio, caja, fecha e importe.
2. Presionar 'Buscar pago'.

**Resultado esperado:**
Se muestran los detalles del pago y sus requerimientos asociados.

**Datos de prueba:**
{ recaud: '001', folio: '12345', caja: 'A1', fecha: '2024-06-01', importe: 1500.00 }

---

## Caso de Uso 2: Aplicar traslado a futuros pagos

**Descripción:** El usuario aplica el traslado de un pago erróneo a futuros pagos.

**Precondiciones:**
El pago debe estar previamente buscado y encontrado.

**Pasos a seguir:**
1. Buscar el pago.
2. Seleccionar 'Futuros pagos' como tipo de aplicación.
3. Ingresar usuario.
4. Presionar 'Aplicar'.

**Resultado esperado:**
El sistema confirma que el traslado fue aplicado a futuros pagos.

**Datos de prueba:**
{ pago_id: 1001, tipo_aplicacion: 'futuros', usuario: 'admin' }

---

## Caso de Uso 3: Liquidar un pago

**Descripción:** El usuario liquida un pago previamente encontrado.

**Precondiciones:**
El pago debe estar previamente buscado y encontrado.

**Pasos a seguir:**
1. Buscar el pago.
2. Presionar el botón 'Liquidar'.

**Resultado esperado:**
El sistema confirma que el pago fue liquidado correctamente.

**Datos de prueba:**
{ pago_id: 1001, usuario: 'admin' }

---

## Casos de Prueba

# Casos de Prueba

## Caso 1: Buscar pago existente
- **Entrada:** recaud='001', folio='12345', caja='A1', fecha='2024-06-01', importe=1500.00
- **Acción:** Buscar pago
- **Esperado:** Se muestra el pago y requerimientos asociados.

## Caso 2: Buscar pago inexistente
- **Entrada:** recaud='999', folio='00000', caja='ZZ', fecha='2024-01-01', importe=9999.99
- **Acción:** Buscar pago
- **Esperado:** Mensaje de 'Pago no encontrado'.

## Caso 3: Aplicar traslado a futuros pagos
- **Precondición:** Pago buscado y encontrado (id=1001)
- **Entrada:** tipo_aplicacion='futuros', usuario='admin'
- **Acción:** Aplicar traslado
- **Esperado:** Mensaje de éxito 'Traslado aplicado correctamente.'

## Caso 4: Aplicar traslado con tipo inválido
- **Precondición:** Pago buscado y encontrado (id=1001)
- **Entrada:** tipo_aplicacion='otro', usuario='admin'
- **Acción:** Aplicar traslado
- **Esperado:** Mensaje de error 'Tipo de aplicación no válido'.

## Caso 5: Liquidar pago
- **Precondición:** Pago buscado y encontrado (id=1001)
- **Entrada:** usuario='admin'
- **Acción:** Liquidar
- **Esperado:** Mensaje de éxito 'Pago liquidado correctamente.'

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

