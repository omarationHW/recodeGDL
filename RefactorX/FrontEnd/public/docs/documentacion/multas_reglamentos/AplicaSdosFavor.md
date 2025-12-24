# Documentación: AplicaSdosFavor

## Análisis Técnico

# Documentación Técnica: Migración de Formulario AplicaSdosFavor (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión y aplicación de saldos a favor derivados de inconformidades en cuentas catastrales. Incluye:
- Consulta de solicitudes de saldo a favor
- Alta de saldo a favor
- Aplicación del saldo a favor a adeudos
- Consulta de detalle de saldos

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `buscarSolicitud`: Busca solicitud de saldo a favor por folio y año
  - `altaSaldoFavor`: Da de alta un saldo a favor
  - `aplicarSaldoFavor`: Aplica el saldo a favor a los adeudos
  - `modificarSaldoFavor`: Modifica el importe del saldo a favor
  - `consultarDetalleSaldos`: Devuelve detalle de saldos de la cuenta

## 4. Frontend (Vue.js)
- Página independiente `/aplica-sdos-favor`
- Permite buscar solicitud, mostrar datos, alta y aplicación de saldo a favor
- Muestra detalle de saldos y mensajes de error/éxito
- No usa tabs ni componentes tabulares

## 5. Stored Procedures
- Toda la lógica de aplicación de saldo a favor y afectación de tablas está en el SP `aplica_saldo_favor` en PostgreSQL
- El SP valida saldo suficiente, registra el pago, actualiza saldos y deja trazabilidad

## 6. Seguridad
- El endpoint requiere autenticación (middleware Laravel)
- El usuario se pasa como parámetro y se valida en el backend

## 7. Manejo de Errores
- Todos los errores se devuelven en el campo `message` del eResponse
- El frontend muestra los mensajes de error y éxito

## 8. Integración
- El frontend usa Axios para consumir el endpoint `/api/execute`
- El backend usa DB::select/insert/update para interactuar con la base y los SP

## 9. Pruebas
- Se incluyen casos de uso y escenarios de prueba para validar la funcionalidad

---

## Casos de Uso

# Casos de Uso - AplicaSdosFavor

**Categoría:** Form

## Caso de Uso 1: Consulta y Alta de Saldo a Favor

**Descripción:** El usuario busca una solicitud de inconformidad y registra un saldo a favor.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el folio y año de la inconformidad.

**Pasos a seguir:**
1. El usuario ingresa el folio y año en el formulario y presiona 'Buscar'.
2. El sistema muestra los datos de la inconformidad y la cuenta.
3. El usuario ingresa el importe a favor y presiona 'Registrar Saldo a Favor'.

**Resultado esperado:**
El saldo a favor queda registrado y visible en la pantalla.

**Datos de prueba:**
folio: 12345, axofol: 2024, importe: 1500.00

---

## Caso de Uso 2: Aplicar Saldo a Favor a Adeudos

**Descripción:** El usuario aplica el saldo a favor a los adeudos de la cuenta.

**Precondiciones:**
Existe un saldo a favor registrado y la cuenta tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca la solicitud y visualiza el saldo a favor.
2. El usuario ingresa el rango de bimestres/años y el importe a aplicar.
3. El usuario presiona 'Aplicar'.

**Resultado esperado:**
El saldo se aplica correctamente, se actualizan los adeudos y el saldo a favor restante.

**Datos de prueba:**
id_solic: 1, cvecuenta: 1001, bimi: 1, axoi: 2024, bimf: 3, axof: 2024, importe: 1200.00

---

## Caso de Uso 3: Consulta de Detalle de Saldos

**Descripción:** El usuario consulta el detalle de saldos de la cuenta para verificar adeudos.

**Precondiciones:**
La cuenta existe y tiene adeudos.

**Pasos a seguir:**
1. El usuario busca la solicitud y visualiza la cuenta.
2. El sistema muestra el detalle de saldos en la tabla inferior.

**Resultado esperado:**
Se visualizan los bimestres/años con adeudo, impuestos y recargos.

**Datos de prueba:**
cvecuenta: 1001

---

## Casos de Prueba

# Casos de Prueba para AplicaSdosFavor

## Caso 1: Buscar solicitud existente
- **Input:** folio=12345, axofol=2024
- **Acción:** buscarSolicitud
- **Esperado:** Devuelve datos de la solicitud, cuenta y contribuyente

## Caso 2: Buscar solicitud inexistente
- **Input:** folio=99999, axofol=2024
- **Acción:** buscarSolicitud
- **Esperado:** Error 'No se encuentra la inconformidad'

## Caso 3: Alta de saldo a favor
- **Input:** id_solic=1, cvecuenta=1001, importe=1500.00, usuario='admin'
- **Acción:** altaSaldoFavor
- **Esperado:** Mensaje de éxito y registro en sdosfavor

## Caso 4: Aplicar saldo a favor insuficiente
- **Input:** id_solic=1, cvecuenta=1001, bimi=1, axoi=2024, bimf=3, axof=2024, importe=99999.00, usuario='admin'
- **Acción:** aplicarSaldoFavor
- **Esperado:** Error 'Saldo a favor insuficiente'

## Caso 5: Aplicar saldo a favor correcto
- **Input:** id_solic=1, cvecuenta=1001, bimi=1, axoi=2024, bimf=3, axof=2024, importe=1200.00, usuario='admin'
- **Acción:** aplicarSaldoFavor
- **Esperado:** Mensaje de éxito y actualización de saldos

## Caso 6: Consulta de detalle de saldos
- **Input:** cvecuenta=1001
- **Acción:** consultarDetalleSaldos
- **Esperado:** Lista de bimestres/años con adeudo, impuestos y recargos

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

