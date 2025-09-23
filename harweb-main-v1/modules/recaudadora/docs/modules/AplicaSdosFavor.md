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
