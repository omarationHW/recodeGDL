# Documentación: DescDerechosMerc

## Análisis Técnico

# Documentación Técnica: Migración Formulario DescDerechosMerc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos en la renta (derechos) de locales en mercados municipales. Incluye:
- Consulta de recaudadoras, mercados, secciones y locales.
- Alta y cancelación de descuentos por periodo y porcentaje.
- Validación de permisos y topes de autorización.
- Lógica de negocio centralizada en stored procedures PostgreSQL.
- API unificada con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- Frontend Vue.js como página independiente.

## 2. Arquitectura
- **Backend:** Laravel Controller (`DescDerechosMercController`) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js (`DescDerechosMercPage.vue`) como página completa.
- **Base de Datos:** PostgreSQL, tabla principal `ta_11_descderechos` y stored procedure `spd_11_descderechosmerc`.

## 3. API (eRequest/eResponse)
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
  - `getRecaudadoras`
  - `getMercados`
  - `getSecciones`
  - `getLocal`
  - `getDescuentosMercado`
  - `altaDescuentoMercado`
  - `cancelaDescuentoMercado`
  - `getPermisosUsuario`
  - `getFuncionarios`

## 4. Stored Procedure Principal
- **Nombre:** `spd_11_descderechosmerc`
- **Parámetros:**
  - `par_local`: ID del local
  - `par_axoi`, `par_mesi`: Periodo inicial (año, mes)
  - `par_axof`, `par_mesf`: Periodo final (año, mes)
  - `par_usuario`: Usuario que realiza la operación
  - `par_porc`: Porcentaje de descuento
  - `par_autoriza`: ID de quien autoriza
  - `par_opc`: 1=alta, 2=cancela
  - `control`: OUT, ID generado
- **Lógica:**
  - Si `par_opc=1`, inserta nuevo descuento vigente.
  - Si `par_opc=2`, cancela descuento vigente para ese local y periodo.

## 5. Validaciones
- No se permite agregar descuento si ya existe uno vigente para el local/periodo.
- El porcentaje no puede exceder el tope autorizado por el funcionario seleccionado.
- El periodo final debe ser mayor o igual al inicial y no mayor al año actual.

## 6. Seguridad
- El usuario debe estar autenticado (JWT o sesión Laravel).
- El backend valida permisos de usuario para autorizar descuentos mayores.

## 7. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para búsqueda de local y visualización de descuentos.
- Formulario para alta de descuento (si no hay vigente).
- Tabla de descuentos vigentes/cancelados.
- Botón para cancelar descuento vigente.
- Mensajes de validación y éxito/error.

## 8. Flujo de Trabajo
1. El usuario selecciona recaudadora, mercado, sección, local, letra y bloque.
2. El sistema busca el local y muestra sus datos.
3. Si hay descuentos vigentes, los muestra en tabla.
4. Si no hay descuento vigente, permite agregar uno nuevo.
5. El usuario ingresa periodo final, porcentaje y selecciona quien autoriza.
6. El sistema valida y ejecuta el stored procedure para alta.
7. El usuario puede cancelar descuentos vigentes desde la tabla.

## 9. Integración
- El frontend se comunica exclusivamente con `/api/execute`.
- Todas las operaciones usan el patrón eRequest/eResponse.
- El backend centraliza la lógica de negocio y validaciones.

## 10. Pruebas y Casos de Uso
- Incluidos en los apartados siguientes.

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

