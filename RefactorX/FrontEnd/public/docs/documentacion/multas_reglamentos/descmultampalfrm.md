# Documentación: descmultampalfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario descmultampalfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos a multas municipales principales. Incluye búsqueda de multas, consulta y registro de descuentos, edición, cancelación y validación de permisos/autorizadores.

## 2. Arquitectura
- **Backend:** Laravel Controller (DescmultampalController.php)
- **Frontend:** Vue.js Single Page Component (DescMultampalPage.vue)
- **Base de Datos:** PostgreSQL, con stored procedures para lógica de negocio
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse

## 3. Flujo de Trabajo
1. El usuario ingresa los datos de búsqueda (dependencia, año, número de acta) y consulta la multa.
2. Si existe, se muestran los datos y el estado de la multa.
3. Si la multa permite descuento, se muestra el formulario de descuento:
   - Tipo de descuento (porcentaje o importe)
   - Valor
   - Autorizador (con tope)
   - Observación
4. El usuario puede agregar, editar o cancelar el descuento vigente.
5. Todas las operaciones se realizan vía `/api/execute` con el campo `action` y los parámetros necesarios.

## 4. Seguridad y Permisos
- El backend valida el usuario autenticado (JWT/session)
- Solo usuarios con permisos pueden ver ciertos autorizadores
- El tope de descuento es validado tanto en frontend como en backend

## 5. Validaciones
- Solo un descuento vigente por multa
- No se puede agregar descuento si la multa está pagada/cancelada/prescrita
- El porcentaje no puede exceder el tope del autorizador
- El importe no puede exceder la calificación de la multa

## 6. API eRequest/eResponse
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
  - buscarMulta
  - consultarDescuento
  - agregarDescuento
  - editarDescuento
  - cancelarDescuento
  - listarAutorizadores
  - listarDependencias

## 7. Stored Procedures
- `sp_descmultampal_agregar`: Alta de descuento
- `sp_descmultampal_editar`: Edición de descuento
- `sp_descmultampal_cancelar`: Cancelación de descuento

## 8. Frontend (Vue.js)
- Página independiente, sin tabs
- Formulario de búsqueda y formulario de descuento
- Validación reactiva
- Mensajes de error y éxito

## 9. Consideraciones de Migración
- Los combos de dependencias y autorizadores se llenan vía API
- El estado de la multa y del descuento se muestra dinámicamente
- El formulario es responsivo y usable en desktop/mobile

## 10. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

