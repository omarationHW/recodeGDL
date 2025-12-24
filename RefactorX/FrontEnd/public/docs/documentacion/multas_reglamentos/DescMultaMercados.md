# Documentación: DescMultaMercados

## Análisis Técnico

# Documentación Técnica: Migración Formulario DescMultaMercados (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel Controller (DescMultaMercadosController.php)
- **Frontend:** Vue.js Single Page Component (DescMultaMercados.vue)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **API:** Endpoint único `/api/execute` con patrón eRequest/eResponse

## 2. Flujo de Trabajo
1. **El usuario accede a la página de descuentos de multas de mercados.**
2. **Selecciona recaudadora, mercado, sección, letra, bloque y local.**
3. **El frontend llama a `/api/execute` con acción `searchLocal` para buscar el local.**
4. **Si el local existe y tiene adeudo, se muestran los descuentos vigentes.**
5. **Si no hay descuento vigente, el usuario puede agregar uno (alta).**
6. **Si hay descuento vigente, puede cancelarlo (baja).**
7. **Todas las operaciones de alta/cancelación llaman al SP `spd_11_descmultamerc`.**

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "module": "DescMultaMercados",
      "action": "searchLocal|getDiscounts|createDiscount|cancelDiscount|getRecaudadoras|getMercados|getSecciones|getFuncionarios",
      "params": { ... },
      "user": "usuario_actual"
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 4. Stored Procedure Principal
- **Nombre:** `spd_11_descmultamerc`
- **Parámetros:**
  - `par_local` (int): ID del local
  - `par_axoi`, `par_mesi`: Periodo inicial (año, mes)
  - `par_axof`, `par_mesf`: Periodo final (año, mes)
  - `par_usuario` (varchar): Usuario
  - `par_porc` (int): Porcentaje
  - `par_autoriza` (int): ID funcionario
  - `par_opc` (int): 1=Alta, 2=Cancelación
- **Retorna:** ID del descuento afectado

## 5. Validaciones
- No se permite registrar más de un descuento vigente por local.
- El porcentaje no puede exceder el tope del funcionario autorizado.
- Solo se permite cancelar descuentos vigentes.

## 6. Seguridad
- El backend valida el usuario y permisos antes de ejecutar acciones.
- El SP sólo permite operaciones válidas según estado y parámetros.

## 7. Consideraciones de Migración
- Todos los combos (recaudadora, mercado, sección, funcionario) se llenan vía API.
- El frontend NO usa tabs, cada formulario es una página independiente.
- El endpoint es único y recibe la acción a ejecutar.
- El frontend muestra mensajes de error y éxito según la respuesta de la API.

## 8. Ejemplo de Uso
- Buscar local:
  - Acción: `searchLocal`
  - Parámetros: `{ ofna, num_merc, categ, secc, local, letra, bloque }`
- Alta descuento:
  - Acción: `createDiscount`
  - Parámetros: `{ id_local, axoi, mesi, axof, mesf, porcentaje, autoriza }`
- Cancelar descuento:
  - Acción: `cancelDiscount`
  - Parámetros: `{ id_local, axoi, mesi, axof, mesf, porcentaje, autoriza }`

## 9. Errores Comunes
- Local no existe o sin adeudo: error en búsqueda.
- Porcentaje mayor al permitido: error en alta.
- Intentar cancelar descuento no vigente: error.

## 10. Pruebas y Auditoría
- Todas las acciones quedan registradas con usuario y fecha en la tabla de descuentos.
- El SP retorna el ID del registro afectado para auditoría.

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

