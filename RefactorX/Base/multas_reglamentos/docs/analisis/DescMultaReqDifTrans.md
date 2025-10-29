# Documentación Técnica: Migración Formulario DescMultaReqDifTrans (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos en multas de requerimientos de diferencias de transmisión patrimonial. Incluye:
- Consulta de folios y diferencias
- Alta de descuentos
- Cancelación de descuentos
- Validación de autorizadores y topes

## 2. Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente, sin tabs)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)
- **Comunicación:** eRequest/eResponse (JSON)

## 3. Endpoints y Acciones
- `/api/execute` (POST)
  - `action: buscarFolio` → Busca descuentos por folio
  - `action: buscarDiferencia` → Busca diferencias con multa vigente
  - `action: altaDescuento` → Da de alta un descuento
  - `action: cancelarDescuento` → Cancela un descuento
  - `action: autorizadores` → Lista de autorizadores válidos para el usuario

## 4. Stored Procedures
- `sp_descmultadiftransm_buscar_folio(folio)`
- `sp_descmultadiftransm_buscar_diferencia(folio)`
- `sp_descmultadiftransm_alta(folio, porcentaje, usuario, autoriza, cvedepto)`
- `sp_descmultadiftransm_cancelar(folio, id_descmulta, usuario)`
- `sp_descmultadiftransm_autorizadores(usuario)`

## 5. Validaciones
- El porcentaje de descuento no puede exceder el tope del autorizador
- Solo se puede cancelar descuentos vigentes
- El usuario debe estar autenticado y tener permisos

## 6. Seguridad
- El usuario y cvedepto se obtienen de la sesión/autenticación
- Todas las operaciones se validan en backend

## 7. Flujo de Uso
1. El usuario ingresa un folio y busca
2. Si existe descuento vigente, se muestra y puede cancelar
3. Si no existe, puede dar de alta un nuevo descuento (seleccionando autorizador y porcentaje)
4. El backend valida y ejecuta el SP correspondiente

## 8. Estructura de la Base de Datos (Tablas principales)
- `descmultadiftransm` (id_descmulta, foliot, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, folio, autoriza, cvedepto)
- `c_autdescmul` (cveautoriza, descripcion, nombre, porcentajetope, vigencia)

## 9. Integración Vue.js
- El componente es una página completa, sin tabs
- Usa axios para consumir `/api/execute`
- Muestra mensajes de error y éxito
- Valida porcentaje antes de enviar

## 10. Pruebas y Casos de Uso
- Incluye casos de uso y escenarios de prueba para validación funcional y de seguridad

---
